package net.chompstation13.manifest;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ManifestController {
	@Autowired
	SocketComponent socket;
	
	@RequestMapping(value = "/api/manifest", method = RequestMethod.GET)
	public String manifest() throws IOException {
		return socket.send(ByteMessages.MANIFEST);
	}

	@RequestMapping(value = "/api/status", method = RequestMethod.GET)
	public String status() throws IOException {
		return socket.send(ByteMessages.STATUS);
	}
}
