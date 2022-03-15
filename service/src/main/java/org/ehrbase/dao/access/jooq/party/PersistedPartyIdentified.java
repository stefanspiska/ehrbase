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

package org.ehrbase.dao.access.jooq.party;

import com.nedap.archie.rm.datavalues.DvIdentifier;
import com.nedap.archie.rm.generic.PartyIdentified;
import com.nedap.archie.rm.generic.PartyProxy;
import com.nedap.archie.rm.support.identification.ObjectId;
import com.nedap.archie.rm.support.identification.PartyRef;
import org.ehrbase.api.exception.InternalServerException;
import org.ehrbase.dao.access.interfaces.I_DomainAccess;
import org.ehrbase.jooq.pg.enums.PartyType;
import org.ehrbase.jooq.pg.tables.records.PartyIdentifiedRecord;

import java.util.List;
import java.util.UUID;

import static org.ehrbase.jooq.pg.Tables.PARTY_IDENTIFIED;

/**
 * PARTY_IDENTIFIED DB operations
 *
 * @author Christian Chevalley
 * @since 1.0
 */
public class PersistedPartyIdentified extends PersistedParty {

    public PersistedPartyIdentified(I_DomainAccess domainAccess) {
        super(domainAccess);
    }

    @Override
    public PartyProxy render(PartyIdentifiedRecord partyIdentifiedRecord) {
        PartyRef partyRef = null;

        if (partyIdentifiedRecord.getPartyRefType() != null) {
            ObjectId objectID = new PersistedObjectId().fromDB(partyIdentifiedRecord);
            partyRef = new PartyRef(objectID, partyIdentifiedRecord.getPartyRefNamespace(), partyIdentifiedRecord.getPartyRefType());
        }

        List<DvIdentifier> identifiers = new PartyIdentifiers(domainAccess)
                .retrieve(partyIdentifiedRecord);

        return new PartyIdentified(partyRef, partyIdentifiedRecord.getName(), identifiers.isEmpty() ? null : identifiers);
    }

    @Override
    public UUID store(PartyProxy partyProxy) {
        PartyRefValue partyRefValue = new PartyRefValue(partyProxy).attributes();

        //store a new party identified
        UUID partyIdentifiedUuid = domainAccess.getContext()
                .insertInto(PARTY_IDENTIFIED,
                        PARTY_IDENTIFIED.NAME,
                        PARTY_IDENTIFIED.PARTY_REF_NAMESPACE,
                        PARTY_IDENTIFIED.PARTY_REF_VALUE,
                        PARTY_IDENTIFIED.PARTY_REF_SCHEME,
                        PARTY_IDENTIFIED.PARTY_REF_TYPE,
                        PARTY_IDENTIFIED.PARTY_TYPE,
                        PARTY_IDENTIFIED.OBJECT_ID_TYPE)
                .values(((PartyIdentified) partyProxy).getName(),
                        partyRefValue.getNamespace(),
                        partyRefValue.getValue(),
                        partyRefValue.getScheme(),
                        partyRefValue.getType(),
                        PartyType.party_identified,
                        partyRefValue.getObjectIdType())
                .returning(PARTY_IDENTIFIED.ID)
                .fetchOne().getId();
        //store identifiers
        new PartyIdentifiers(domainAccess).store((PartyIdentified) partyProxy, partyIdentifiedUuid);

        return partyIdentifiedUuid;
    }

    /**
     * Retrieve a party identified by:
     * External Ref
     * if none, by matching name and matching identifiers if any
     *
     * @param partyProxy
     * @return
     */
    @Override
    public UUID findInDB(PartyProxy partyProxy) {
        UUID uuid = new PersistedPartyRef(domainAccess).findInDB(partyProxy.getExternalRef());

        //check that name matches the one already stored in DB, otherwise throw an exception (conflicting identification)
        if (uuid != null) {
            PartyIdentifiedRecord fetchedRecord =
                    domainAccess.getContext().fetchAny(PARTY_IDENTIFIED, PARTY_IDENTIFIED.ID.eq(uuid));
            if (fetchedRecord == null) {
                throw new InternalServerException("Inconsistent PartyIdentified UUID:" + uuid);
            }

            if (!fetchedRecord.getName().equals(((PartyIdentified) partyProxy).getName())) {
                throw new IllegalArgumentException(
                        "Conflicting identification, existing name was:" +
                                fetchedRecord.getName() +
                                ", but found passed name:" +
                                ((PartyIdentified) partyProxy).getName());
            }
        }

        return uuid;
    }

}
