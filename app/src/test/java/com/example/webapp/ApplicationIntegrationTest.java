package com.example.webapp;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for the Simple Java WebApp application
 */
@SpringBootTest
@AutoConfigureMockMvc
public class ApplicationIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testApplicationLoads() {
        // This test simply verifies that the application context loads without errors
    }

    @Test
    public void testRootEndpointIsAccessible() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk());
    }

    @Test
    public void testRootEndpointDisplaysHelloMessage() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("hello from Java")));
    }

    @Test
    public void testRootEndpointResponseType() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith("text/html"));
    }

    @Test
    public void testPageContainsProperHtmlStructure() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("<html")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("<head")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("<body")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("</body>")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("</html>")));
    }
}
