const puppeteer = require('puppeteer');
var fs = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('file:///Users/mmorga/projects/topobook/TX_Mesa_De_Anguila_20160205_TM_geo/TX_Mesa_De_Anguila_20160205_TM_geo-noimg.svg');

  await page.setViewport({width: 1200, height: 1800});

  // Get the "viewport" of the page, as reported by the page.
  // const dimensions = await page.evaluate(() => {
  //   return {
  //     width: document.documentElement.clientWidth,
  //     height: document.documentElement.clientHeight,
  //     deviceScaleFactor: window.devicePixelRatio
  //   };
  // });
  // console.log('Dimensions:', dimensions);

  const name = await page.evaluate(() => {
    function rmAll(list) {
      list.forEach(el => el.parentNode.removeChild(el))
    };

    s = document.querySelector("svg");
    s.setAttribute('width', '1200');
    s.setAttribute('height', '1800');

    rmAll(document.querySelectorAll('mask'));
    rmAll(document.querySelectorAll('symbol'));
    // Remove streams, rivers, etc.
    rmAll(document.querySelectorAll('[style*="rgb(74.499512%,90.99884%,100%)"]'));
    // Remove lighter topo lines
    rmAll(document.querySelectorAll('[style*="rgb(70.199585%,52.49939%,34.899902%)"]'));

    // Remove groups
    var groups = document.querySelectorAll('g');
    groups.forEach(groupNode => {
      var childNodes = Array.prototype.slice.call(groupNode.childNodes);
      childNodes.forEach(childNode => groupNode.parentNode.insertBefore(childNode, groupNode));
    });
    rmAll(groups);
  });

  await page.screenshot({path: 'example.png'});

  const svgContent = await page.content();

  fs.writeFile("processed.svg", svgContent, function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
  });
  await browser.close();
})();
