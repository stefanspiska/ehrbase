package org.ehrbase;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.junit.jupiter.api.*;

public class ApiDummyTest {

    private static final Logger log = LoggerFactory.getLogger(ApiDummyTest.class);

    @Test
    @DisplayName("Api Module Dummy Test")
    void apiDummyTest() {
        log.error("1. Hello API");
        log.info("I'm here for  reference and to make sure test results are send to reportportal properly");
        Assertions.assertEquals("Apple", "Apple");
    }
}
