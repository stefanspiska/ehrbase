/*
 * Copyright 2020-2022 vitasystems GmbH and Hannover Medical School.
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

package org.ehrbase.service;

import org.ehrbase.api.definitions.ServerConfig;
import org.ehrbase.api.service.StatusService;
import org.ehrbase.dao.access.interfaces.I_DatabaseStatusAccess;
import org.jooq.DSLContext;
import org.springframework.boot.info.BuildProperties;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.lang.management.ManagementFactory;

/**
 * @author Axel Siebert
 * @since 1.0
 */
@Service
@Transactional
public class StatusServiceImp extends BaseServiceImp implements StatusService {

    private final BuildProperties buildProperties;

    public StatusServiceImp(KnowledgeCacheService knowledgeCacheService, DSLContext dslContext,
                            ServerConfig serverConfig, BuildProperties buildProperties) {
        super(knowledgeCacheService, dslContext, serverConfig);
        this.buildProperties = buildProperties;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getOperatingSystemInformation() {
        return String.format(
                "%s %s %s",
                ManagementFactory.getOperatingSystemMXBean().getName(),
                ManagementFactory.getOperatingSystemMXBean().getArch(),
                ManagementFactory.getOperatingSystemMXBean().getVersion()
        );
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getJavaVMInformation() {
        return String.format(
                "%s %s",
                ManagementFactory.getRuntimeMXBean().getVmVendor(),
                ManagementFactory.getRuntimeMXBean().getSystemProperties().get("java.runtime.version")
        );
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getDatabaseInformation() {
        return I_DatabaseStatusAccess.retrieveDatabaseVersion(getDataAccess());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getEhrbaseVersion() {
        return this.buildProperties.getVersion();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getArchieVersion() {
        return this.buildProperties.get("archie.version");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getOpenEhrSdkVersion() {
        return this.buildProperties.get("openEHR_SDK.version");
    }
}
