package org.ehrbase;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.junit.jupiter.api.*;

import java.io.IOException;



public class MyServiceTest {

    private static final Logger log = LoggerFactory.getLogger(MyServiceTest.class);

    @Test
    void mySimpleServiceTest() throws IOException {
        log.warn("2. Hello SERVICE WARNING");
        Assertions.assertEquals("Apfel", "Apfel");

    }
}
