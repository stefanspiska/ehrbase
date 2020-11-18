package org.ehrbase;

// import org.apache.logging.log4j.LogManager;
// import org.apache.logging.log4j.Logger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.junit.jupiter.api.*;

public class MyOpenehrTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(MyOpenehrTest.class);

    @Test
    void testMySimpleTest() {
        LOGGER.error("5. Hello OPENEHR");
    }
}
