package org.ehrbase;

// import org.apache.logging.log4j.LogManager;
// import org.apache.logging.log4j.Logger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.junit.jupiter.api.*;

public class MyBaseTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(MyBaseTest.class);

    @Test
    void testMySimpleTest() {
        LOGGER.error("3. Hello BASE");
    }
}
