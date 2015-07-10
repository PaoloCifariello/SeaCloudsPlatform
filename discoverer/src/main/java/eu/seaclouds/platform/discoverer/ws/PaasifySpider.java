/**
 * Copyright 2014 SeaClouds
 * Contact: SeaClouds
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package eu.seaclouds.platform.discoverer.ws;

import alien4cloud.tosca.parser.ParsingException;
import eu.seaclouds.platform.discoverer.core.Offering;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class PaasifySpider extends SCSpider {

    /** Temporary directory where paasify repository will be put */
    private final String defaultTempDirectory = "/Users/paolocifariello/tmp/"; //System.getProperty("java.io.tmpdir");

    /** Directory path where paas-profiles repository will be put in */
    private final String paasifyRepositoryDirecory = defaultTempDirectory + "paas-profiles";

    /** Paasify GitHub repository URL */
    private final String paasifyRepositoryURL = "https://github.com/stefan-kolb/paas-profiles/";

    private JSONParser jsonParser = new JSONParser();
    private static HashMap<String, String> paasifyToSeaclouds;

    static {
        HashMap<String, String> initializedMap = new HashMap<>();

        /** Initialized map from paasify to Seaclouds keywords */
        initializedMap.put("java", "java_support");
        initializedMap.put("go", "go_support");
        initializedMap.put("node", "node_support");
        initializedMap.put("php", "php_support");
        initializedMap.put("python", "python_support");
        initializedMap.put("ruby", "ruby_support");

        paasifyToSeaclouds = initializedMap;
    }

    /**
     * Initializes a temporary directory and clones paasify repository in it
     */
    public PaasifySpider() {

        File tempDirectory = new File(defaultTempDirectory, "paas-profiles");

        /** Create paasify-offerings directory into os temp directory if it has not been created yet */
        if (!tempDirectory.exists()) {
            tempDirectory.mkdir();

            try {
                Git.cloneRepository()
                        .setURI(paasifyRepositoryURL)
                        .setDirectory(tempDirectory)
                        .call();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Synchronizes with paasifiy repository and get updated offerings
     *
     * @return the array of offerings that have been successfully converted into SeaClouds offerings
     */
    public CrawlingResult[] crawl() {

        CrawlingResult[] offerings = null;

        try {
            updateLocalRepository();
            offerings = getOfferings();
        } catch (Exception e){
            e.printStackTrace();
        }

        return offerings;
    }

    /**
     * Updates local Paasify repository
     *
     * @throws GitAPIException
     */
    private void updateLocalRepository() throws GitAPIException {

        try {
            Git.open(new File(paasifyRepositoryDirecory)).pull().call();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     *
     * @return an array offerings successfully translated into SeaClouds offering format
     */
    private CrawlingResult[] getOfferings() {

        File offeringsDirectory = new File(paasifyRepositoryDirecory + "/profiles");
        ArrayList<CrawlingResult> offers = new ArrayList<>();

        for (File offerFile : offeringsDirectory.listFiles()) {
            try {
                if (offerFile.isFile() && isJSON(offerFile)) {
                    JSONObject obj =(JSONObject) jsonParser.parse(new FileReader(offerFile));
                    CrawlingResult currentOffering = convertToTOSCA(obj);
                    offers.add(currentOffering);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return offers.toArray(new CrawlingResult[offers.size()]);
    }

    /**
     * Conversion from Paasify JSON model into TOSCA PaaS model
     *
     * @param obj the decoded JSON offering
     * @return the converted JSON offering into a SeaClouds Offering
     *
     * @throws ParsingException
     * @throws IOException
     */
    private CrawlingResult convertToTOSCA(JSONObject obj) throws ParsingException, IOException {
        ArrayList<String> generatedTOSCA = new ArrayList<>();

        String name = (String) obj.get("name");
        name = Offering.sanitizeName(name);

        generatedTOSCA.add("tosca_definitions_version: tosca_simple_yaml_1_0_0_wd03");
        generatedTOSCA.add("imports:");
        generatedTOSCA.add("  - tosca-normative-types:1.0.0.wd03-SNAPSHOT");
        generatedTOSCA.add("topology_template:");
        generatedTOSCA.add(" node_templates:");
        generatedTOSCA.add(String.format("  %s:", name));
        generatedTOSCA.add(String.format("    type: seaclouds.Nodes.Platform.%s", name));
        generatedTOSCA.add("    properties:");

        JSONArray runtimes = (JSONArray) obj.get("runtimes");

        for (int i = 0; i < runtimes.size(); i++) {
            JSONObject runtime = (JSONObject) runtimes.get(i);
            String currentLanguage = (String) runtime.get("language");

            String runtimeSupportTag = paasifyToSeaclouds.get(currentLanguage);

            if (runtimeSupportTag != null)
                generatedTOSCA.add(String.format("      %s: true", runtimeSupportTag));
        }

        Offering off = Offering.fromTosca(String.join("\n", generatedTOSCA));
        DateFormat df = new SimpleDateFormat("yyyy-mm-dd");
        Date lastRevision;

        try {
            lastRevision = df.parse((String) obj.get("revision"));
        } catch (Exception e) {
            e.printStackTrace();
            lastRevision = Calendar.getInstance().getTime();
        }

        return new CrawlingResult(lastRevision, off);
    }

    private boolean isJSON(File file) {
        String fileName = file.getName();
        String fileExtension = "";

        if(fileName.lastIndexOf(".") != -1 && fileName.lastIndexOf(".") != 0)
            fileExtension = fileName.substring(fileName.lastIndexOf(".")+1);

        return fileExtension.equals("json");
    }
}