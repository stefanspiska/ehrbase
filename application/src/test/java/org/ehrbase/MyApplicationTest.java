package org.ehrbase;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.Assertions;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;



public class MyApplicationTest {

    private static final Logger log = LoggerFactory.getLogger(MyApplicationTest.class);
    public enum TestParams {
		ONE,
		TWO
	}

    @Test
    void mySimpleTest() {

        log.trace("2. Hello APPLICATION TRACE");
        log.debug("2. Hello APPLICATION DEBUG");
        log.info("2. Hello APPLICATION INFO");
        log.warn("2. Hello APPLICATION WARNING");
        log.error("2. Hello APPLICATION ERROR");
        
        System.out.println("Hello ReportPortal!");
        Assertions.assertEquals("Apple", "Apple");
    }

    @ParameterizedTest
	@EnumSource(TestParams.class)
	void testParameters(TestParams param) {
		System.out.println("Test: " + param.name());
	}
}
