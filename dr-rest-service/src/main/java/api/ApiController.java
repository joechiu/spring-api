package api;

import org.springframework.web.bind.annotation.*;
import org.springframework.core.io.*;
import java.security.MessageDigest;
import org.springframework.http.*;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import javax.servlet.http.HttpServletRequest;
import java.util.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.io.*;

@RestController
public class ApiController {

    // implement the caching machanism, default false
    private boolean NOCACHE;
    // clean the cache is yes/true
    private boolean CCLEAN;
    // keep the caches less than the day provided
    private int DAY;
    private String URL="http://eland.nz:8080";
    // cache functions
    private String PRM = "/opt/dr/scripts/spring-api.pl";
    // initiate logger
    private static final Logger logger = LogManager.getLogger(ApiController.class);
    // encrypted md5 hex auth
    private static final String AUTH = "a61f31c93e391a06f23235f3dea7bda7";

    @RequestMapping("/cache")
    public String cache(
	    @RequestHeader(value="Auth") String auth,
	    @RequestParam(value="clean", defaultValue="false") boolean cc,
	    @RequestParam(value="day", defaultValue="0") int day,
	    HttpServletRequest request
	) {

	CCLEAN = cc;
	DAY = day;

	if (!md5hex(auth).equals(AUTH)) {
	    logger.info("["+request.getRemoteAddr()+"] Incorrect Authentication: '" + auth + "'");
	    return "Incorrect Authentication: '" + auth + "'";
	}

	if (!cc) {
	    String api = URL + "/cache?clean=1";
	    return "Invalid params\n" + 
		    "Usage: "+api+" or "+api+"&day=30";
	}
        return cmd("cache", "");
    }

    @RequestMapping(value = "/query", method = RequestMethod.GET, produces = "text/csv")
    public ResponseEntity<Resource> downloadCSV(
	    @RequestParam String pickdate, 
	    @RequestParam(value="nocache", defaultValue="false") boolean nc,
	    HttpServletRequest request
	) throws IOException {

	logger.info("["+request.getRemoteAddr()+"] "+requestInfo(request));

	NOCACHE = nc;

	File CSVFile = getFile(pickdate);
	Path path = Paths.get(CSVFile.getAbsolutePath());
	ByteArrayResource resource = new ByteArrayResource(Files.readAllBytes(path));

	HttpHeaders headers = new HttpHeaders(); 
	headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=cat-trip-"+pickdate+".csv");

	return ResponseEntity.ok()
		.headers(headers)
		.contentLength(CSVFile.length())
		.contentType(MediaType.parseMediaType("application/octet-stream"))
		.body(resource);

    }

    private File getFile(String pickdate) throws FileNotFoundException {

        if (pickdate == ""){
	    logger.info("error: invalid pick date (ex. yyyy-mm-dd)");
            throw new FileNotFoundException("error: invalid pick date (ex. yyyy-mm-dd)");
        }

        String filepath = cmd("query", pickdate);

	if (!filepath.contains(md5hex(pickdate))) {
	    logger.info("error: pickdate and filepath is not identical");
	    throw new FileNotFoundException("error: pickdate and filepath is not identical");
	}

        File file = new File(filepath);

        return file;
    }

    private String cmd(String act, String pickdate) {

	String cmd;
	if (act == "query") {
	    cmd = PRM + " " + act + " " + pickdate + " " + NOCACHE;
	} else {
	    cmd = PRM + " " + act + " 0 0 " + CCLEAN + " " + DAY;
	}

        String s;
        Process p;

        try {
	    String res = "";
            p = Runtime.getRuntime().exec(cmd);
            BufferedReader br = new BufferedReader(
                new InputStreamReader(p.getInputStream()));
            while ((s = br.readLine()) != null) res += s;
            p.waitFor();
            logger.info("process status: " + p.exitValue());
            p.destroy();

	    return res;
        } catch (Exception e) {
            logger.error("exec failed: " + e);
	}

	return "";
    }

    public static String md5hex(String string) {
        byte[] hash;
        try {
            hash = MessageDigest.getInstance("MD5").digest(string.getBytes("UTF-8"));
            return enCode(hash);
        } catch (Exception e) {
            return null;
        }

    }
    private static String enCode(byte[] bytes) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < bytes.length; i++) {
            byte b = bytes[i];
            String hex = Integer.toHexString((int) 0x00FF & b);
            if (hex.length() == 1) {
                sb.append("0");
            }
            sb.append(hex);
        }
        return sb.toString();
    }

    private static String getClientIp(HttpServletRequest request) {

        String remoteAddr = "";

        if (request != null) {
            remoteAddr = request.getHeader("X-FORWARDED-FOR");
            if (remoteAddr == null || "".equals(remoteAddr)) {
                remoteAddr = request.getRemoteAddr();
            }
        }

        return remoteAddr;
    }

    private String requestInfo(HttpServletRequest request) {

        Map<String, String> map = new HashMap<String, String>();

        Enumeration headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String key = (String) headerNames.nextElement();
            String value = request.getHeader(key);
            map.put(key, value);
        }
        return map.toString();
    }

}
