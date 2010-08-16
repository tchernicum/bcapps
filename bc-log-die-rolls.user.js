// ==UserScript==
// @name bc-log-die-rolls.users.js
// @namespace http://conquerclub.barrycarter.info/
// @description Logs all conquerclub.com die rolls to central server
// intentionally not putting http below, I want to match files too
// @include *conquerclub*
// ==/UserScript==

// only invoke this script when someone hits 'assault'
document.getElementById('mydice').addEventListener("click", logroll)

// TODO: production include is: http://www.conquerclub.com/game.php?game=*

// currently in testing mode as I learn greasemonkey/JS
// test page:
// http://conquerclub.barrycarter.info/TEST/conquerclub.snapshot.diceroll.html

// v=1 means version=1 but also means I can use '&var=val' below

function logroll() {

// TODO: change this URL
var url = "http://ns1.conquerdata.barrycarter.info/rec.php?v=1";

// get the game number
var gameno = document.evaluate('//input[@type="hidden"][@name="game"]/@value',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

url = url+"&g="+gameno.snapshotItem(0).value;

// the attackers rolls

var attack = document.evaluate('//ul[@class="attack"]/li',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

for (i=0; i<attack.snapshotLength; i++) {
 var val = (attack.snapshotItem(i).childNodes)[0].textContent;
 url=url+"&ad="+val;
 }

// defender rolls (redundant code, blech!)

var defend = document.evaluate('//ul[@class="defend"]/li',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

for (i=0; i<defend.snapshotLength; i++) {
 var val = (defend.snapshotItem(i).childNodes)[0].textContent;
 url=url+"&dd="+val;
 }

// attacker (country)

var attacker = document.evaluate('//p[@class="attacker"]',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

attacker = (attacker.snapshotItem(0).childNodes)[0].textContent

url = url+"&at="+attacker;

GM_xmlhttpRequest({method: "GET", url: url});

GM_log(url);

}
