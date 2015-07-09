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

/* servlet */
import eu.seaclouds.platform.discoverer.core.Discoverer;
import eu.seaclouds.platform.discoverer.core.Offering;

import javax.servlet.http.HttpServlet;

/* utils */
import java.util.*;

@SuppressWarnings("serial")
public class CrawlerManager extends HttpServlet implements Runnable {
	/* consts */
	private static final int SLEEP_SECONDS = 5*60; // 5 mins
	
	/* vars */
	private Thread backThread;
	private int tick;



	private void updateRepository(Hashtable<String, CrawlingResult> collected) {
		/* special case */
		if(collected.size() == 0)
			return;

		/* summary of the current content of the repo */
		Hashtable<String, String> summary = new Hashtable<String, String>();
		Discoverer discoverer = Discoverer.instance();
		Iterator<String> offerIds = discoverer.enumerateOffers();
		while(offerIds.hasNext()) {
			String oid = offerIds.next();
			Offering o = discoverer.fetch(oid);
			summary.put(o.getName(), o.getId());
		}

		/* update */
		Set<String> oNames = collected.keySet();
		for(String on : oNames) {
			/* checking presence into repo. */
			String id = summary.get(on);
			if(id == null) {
				/* add the new offering to the repo */
				discoverer.addOffer(collected.get(on).offering);
			} else {
				/* establish most recent */
				Date newDate = collected.get(on).date;
				Date oldDate = discoverer.getDate(id);
				if(newDate.compareTo(oldDate) > 0) {
					/* update */
					discoverer.removeOffer(id);
					discoverer.addOffer(collected.get(on).offering);
				}
			}
		}

		/* hints for garbage collector */
		summary = null;
		return;
	}


	/* *********************************************************** */
	/* *****                  back thread                    ***** */
	/* *********************************************************** */
	
	private void run_helper() throws InterruptedException {
		
		/* init. spiders */
		Vector<SCSpider> spiders = new Vector<SCSpider>();
		// spider.add(new PaaSifySpider());
		Hashtable<String, CrawlingResult> collectedOfferings
				= new Hashtable<String, CrawlingResult>();
		
		/* endless main loop */
		while(true)
		{
			/* init. offering collection */
			collectedOfferings.clear();

			/* crawl */
			for(SCSpider spid : spiders) {
				CrawlingResult[] crs = spid.crawl();
				for(CrawlingResult cr : crs) {
					String offeringName = cr.offering.getName();
					collectedOfferings.put(offeringName, cr);
				}
			}

			/* update repo */
			updateRepository(collectedOfferings);

			/* wait for next tick */
			Thread.sleep(tick);
		}
		
	}
	
	
	@Override
	public void run() {
		
		try { run_helper(); }
		catch(Exception ex) { ex.printStackTrace();	}
		
	}
	
	
	/* *********************************************************** */
	/* *****                    servlet                      ***** */
	/* *********************************************************** */
	
	public void init() {
		this.tick = 1000*this.SLEEP_SECONDS;
		this.backThread = new Thread(this);
		backThread.start();
	}	
	
	
	
	
}
