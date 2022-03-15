/*
 * Copyright 2019-2022 vitasystems GmbH and Hannover Medical School.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.ehrbase.rest.ehrscape.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.nedap.archie.rm.ehr.EhrStatus;
import com.nedap.archie.rm.generic.PartySelf;
import com.nedap.archie.rm.support.identification.HierObjectId;
import com.nedap.archie.rm.support.identification.PartyRef;
import org.apache.commons.lang3.StringUtils;
import org.ehrbase.api.exception.InvalidApiParameterException;
import org.ehrbase.api.service.EhrService;
import org.ehrbase.response.ehrscape.EhrStatusDto;
import org.ehrbase.response.ehrscape.StructuredString;
import org.ehrbase.response.ehrscape.StructuredStringFormat;
import org.ehrbase.rest.ehrscape.responsedata.Action;
import org.ehrbase.rest.ehrscape.responsedata.EhrResponseData;
import org.ehrbase.rest.ehrscape.responsedata.Meta;
import org.ehrbase.rest.ehrscape.responsedata.RestHref;
import org.ehrbase.serialisation.jsonencoding.CanonicalJson;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/**
 * Controller for /ehr resource of EhrScape REST API
 *
 * @author Stefan Spiska
 * @author Jake Smolka
 * @since 1.0
 */
@RestController
@RequestMapping(path = "/rest/ecis/v1/ehr")
public class EhrController extends BaseController {

    private static final String MODIFIABLE = "modifiable";

    private static final String QUERYABLE = "queryable";

    private final EhrService ehrService;

    public EhrController(EhrService ehrService) {
        this.ehrService = Objects.requireNonNull(ehrService);
    }

    @PostMapping
    @ResponseStatus(value = HttpStatus.CREATED)
    // overwrites default 200, fixes the wrong listing of 200 in swagger-ui (EHR-56)
    public ResponseEntity<EhrResponseData> createEhr(
            @RequestParam(value = "subjectId", required = false) String subjectId,
            @RequestParam(value = "subjectNamespace", required = false) String subjectNamespace,
            @RequestParam(value = "committerId", required = false) String committerId,
            @RequestParam(value = "committerName", required = false) String committerName,
            @RequestHeader(value = "Content-Type", required = false) String contentType,
            @RequestBody(required = false) String content) {

        // subjectId and subjectNamespace are not required by EhrScape spec but without those parameters a 400 error shall be returned
        if ((subjectId == null) || (subjectNamespace == null)) {
            throw new InvalidApiParameterException("subjectId or subjectNamespace missing");
        } else if ((subjectId.isEmpty()) || (subjectNamespace.isEmpty())) {
            throw new InvalidApiParameterException("subjectId or subjectNamespace emtpy");
        }
        EhrStatus ehrStatus = extractEhrStatus(content);
        PartySelf partySelf = new PartySelf(
                new PartyRef(new HierObjectId(subjectId), subjectNamespace, null));
        ehrStatus.setSubject(partySelf);
        UUID ehrId = ehrService.create(ehrStatus, null);

        return Optional.ofNullable(ehrId)
                .flatMap(i -> buildEhrResponseData(i, Action.CREATE))
                .map(body -> {
                    var location = ServletUriComponentsBuilder.fromCurrentRequest()
                            .pathSegment("/{ehrId}")
                            .build(ehrId);
                    return ResponseEntity.created(location).body(body);
                })
                .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
    }

    @GetMapping
    public ResponseEntity<EhrResponseData> getEhr(@RequestParam(value = "subjectId") String subjectId,
                                                  @RequestParam(value = "subjectNamespace") String subjectNamespace,
                                                  @RequestHeader(value = "Content-Type", required = false) String contentType) {

        Optional<UUID> ehrId = ehrService.findBySubject(subjectId, subjectNamespace);
        return ehrId.flatMap(i -> buildEhrResponseData(i, Action.RETRIEVE))
                .map(ResponseEntity::ok).orElse(ResponseEntity.noContent().build());
    }

    @GetMapping(path = "/{uuid}")
    public ResponseEntity<EhrResponseData> getEhr(@PathVariable("uuid") UUID ehrId,
                                                  @RequestHeader(value = "Content-Type", required = false) String contentType) {

        return Optional.ofNullable(ehrId)
                .flatMap(i -> buildEhrResponseData(i, Action.RETRIEVE)).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping(path = "/{uuid}/status")
    public ResponseEntity<EhrResponseData> updateStatus(@PathVariable("uuid") UUID ehrId,
                                                        @RequestBody() String ehrStatus,
                                                        @RequestHeader(value = "Content-Type", required = false) String contentType) {

        ehrService.updateStatus(ehrId, extractEhrStatus(ehrStatus), null);
        return Optional.ofNullable(ehrId)
                .flatMap(i -> buildEhrResponseData(i, Action.UPDATE)).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    private EhrStatus extractEhrStatus(@RequestBody String content) {
        EhrStatus ehrStatus = new EhrStatus();

        if (StringUtils.isNotBlank(content)) {
            Gson json = new GsonBuilder().create();
            Map<String, Object> atributes = json.fromJson(content, Map.class);

            if (atributes.containsKey(MODIFIABLE)) {
                ehrStatus.setModifiable((Boolean) atributes.get(MODIFIABLE));
            }

            if (atributes.containsKey(QUERYABLE)) {
                ehrStatus.setQueryable((Boolean) atributes.get(QUERYABLE));
            }
        }
        return ehrStatus;
    }

    private Optional<EhrResponseData> buildEhrResponseData(UUID ehrId, Action create) {
        return ehrService.getEhrStatus(ehrId)
                .map(ehrStatus -> {
                    var response = new EhrResponseData();
                    response.setAction(create);
                    response.setEhrId(ehrId);

                    var meta = new Meta();
                    var href = new RestHref();
                    href.setUrl(ServletUriComponentsBuilder.fromCurrentRequest()
                            .path("/rest/ecis/v1/ehr/{ehrId}")
                            .build(ehrId)
                            .toString());
                    meta.setHref(href);
                    response.setMeta(meta);

                    var dto = new EhrStatusDto();
                    dto.setSubjectId(ehrStatus.getSubject().getExternalRef().getId().getValue());
                    dto.setSubjectNamespace(ehrStatus.getSubject().getExternalRef().getNamespace());
                    dto.setModifiable(ehrStatus.isModifiable());
                    dto.setQueryable(ehrStatus.isQueryable());
                    dto.setOtherDetails(new StructuredString(new CanonicalJson().marshal(ehrStatus.getOtherDetails()), StructuredStringFormat.JSON));
                    return response;
                });
    }
}
