(function() {
	const DEPARTMENTS = {
		"heads": "Command",
		"sec": "Security",
		"eng": "Engineering",
		"med": "Medical",
		"sci": "Research",
		"car": "Cargo",
		"pla": "Exploration",
		"civ": "Civilian",
		"bot": "Silicon",
		"misc": "Miscellaneous",
		"off": "Offmap",
	}
	
	var table;
	var crew_map = {};
	
	function init() {
		table = document.getElementById("manifest");
		reload();
		setInterval(reload, 60000);
	}
	
	function get(url) {
		return fetch(url).then(function (response) {
			if (response.ok) {
				return response.text();
			} else {
				throw new Error(response.status);
			}
		});
	}
	
	function reload() {
		get("api/status").then(printStatus).catch(console.error);
		get("api/manifest").then(printManifest).catch(console.error);
	}
	
	function printStatus(status) {
		const statusMap = new URLSearchParams(status);
		document.getElementById("round-duration").innerText = statusMap.get("roundduration");
		document.getElementById("online-player").innerText = statusMap.get("players");
	}
	
	function printManifest(manifest) {
		const departments = new URLSearchParams(manifest);
		const tbodies = document.getElementsByTagName("tbody");
		for (let i = tbodies.length - 1; i > -1; i--) tbodies[i].remove();
		
		crew_map = {};
		for (const department of Object.keys(DEPARTMENTS)) try {
			const lists = departments.get(department);
			if (lists) printDepartment(department, lists);
		} catch (error) {
			console.error(error);
		}
		document.getElementById("crew-member").innerText = Object.keys(crew_map).length;
	}
	
	function printDepartment(department, lists) {
		const d = DEPARTMENTS[department];
		if (!d) d = DEPARTMENTS.misc;
		
		const tbody = document.createElement("tbody");
		tbody.innerHTML = `<tr class="department"><td colspan="3">${d}</td></tr>`;
		
		const l = new URLSearchParams(lists);
		const mapping = {};
		for (const [name, value] of l.entries()) {
			if (!mapping[name]) mapping[name] = {};
			const v = mapping[name];
			v.name = name;
			if (value === "Active" || value === "Inactive") v.activity = value;
			else v.rank = value;
		}
		
		for (const o of Object.values(mapping)) {
			const tr = document.createElement("tr");
			tr.innerHTML =
			`<td class="name">${o.name}</td><td class="rank">${o.rank}</td><td class="acti">${o.activity}</td>`;
			crew_map[o.name] = true;
			tbody.append(tr);
		}
		
		table.append(tbody);
	}
	
	document.addEventListener("DOMContentLoaded", init);
})()
