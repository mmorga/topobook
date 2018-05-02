const puppeteer = require('puppeteer');
var fs = require('fs');

(async () => {
  const browser = await puppeteer.launch({dumpio: true});
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

  const names = await page.evaluate(() => {
    function rmAll(list) {
      list.forEach(el => el.parentNode.removeChild(el))
    };

    function toArray(l) {
      return Array.prototype.slice.call(l);
    }

    function tagsInSvg(nodes) {
      var nodeAry = toArray(nodes);
      var names = new Set();
      nodeAry.map(node => node.nodeName).reduce((accumulator, name) => names.add(name), names);
      var namesAry = [];
      names.forEach(name => namesAry.push(name));
      return namesAry;
    }

    function moveContentOutOfGroups() {
      var groups = document.querySelectorAll('g');
      groups.forEach(groupNode => {
        var style = "";
        if (groupNode.hasAttribute("style")) {
          style = groupNode.attributes["style"].value;
        }

        var childNodes = Array.prototype.slice.call(groupNode.children);
        childNodes.forEach(childNode => {
          if (style.length > 0) {
            var computedStyle = window.getComputedStyle(childNode);
            childNode.setAttribute("style", computedStyle.cssText);
          }
          groupNode.parentNode.insertBefore(childNode, groupNode);
        });
      });
      rmAll(groups);
    }

    function setSvgWidthHeight(bb) {
      var svg = document.rootElement;
      svg.setAttribute('width', '1200');
      svg.setAttribute('height', '1800');
      svg.setAttribute('viewBox', `${bb.x} ${bb.y} ${bb.width} ${bb.height}`);
      var bbRect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
      bbRect.setAttribute('x', bb.x);
      bbRect.setAttribute('y', bb.y);
      bbRect.setAttribute('width', bb.width);
      bbRect.setAttribute('height', bb.height);
      bbRect.setAttribute('stroke', 'red');
      bbRect.setAttribute('stroke-width', '4');
      bbRect.setAttribute('fill', 'none');
      svg.appendChild(bbRect);
    }

    function clientBBs() {
      var nodes = toArray(document.querySelectorAll("path")); // rect,path,use
      return nodes.map(node => {
        var rect = node.getBoundingClientRect();
        return {x: rect.x, y: rect.y, width: rect.width, height: rect.height, node: node};
      });
    }

    function largestBB() {
      const reducer = (acc, bb) => {
        const style = window.getComputedStyle(bb.node);
        const stroke = style.getPropertyValue('stroke');
        const fill = style.getPropertyValue('fill');
        if ((stroke == 'none' || stroke == 'rgb(255,255,255)') &&
          (fill == 'none' || fill == 'rgb(255,255,255)')) {
          return acc;
        }
        if ((bb.width >= acc.width) && (bb.height >= acc.height)) {
          console.log(`stoke: ${style.stroke}, fill: ${style.fill}`);
          return bb;
        }
        return acc;
      };
      return clientBBs().reduce(reducer, {x: 0, y: 0, width: 0, height: 0});
    }

    function cleanUpOutside(rectangle) {
      var svg = document.rootElement;
      var nodes = document.querySelectorAll('rect,path,use');
      var rect = svg.createSVGRect();
      rect.x = rectangle.x;
      rect.y = rectangle.y;
      rect.height = rectangle.height;
      rect.width = rectangle.width;

      nodes.forEach(node => {
        if (!svg.checkIntersection(node, rect)) {
          node.parentNode.removeChild(node);
        }
      });
    }

    function scaleStrokes() {
      var svg = document.rootElement;
      var nodes = document.querySelectorAll('[stroke-width]');
      nodes.forEach(node => {
        var strokeWidth = Math.trunc(Number.parseFloat(node.getAttribute('stroke-width')) * 10.0);
        node.setAttribute('stroke-width', `${strokeWidth}`)
      });
      var nodes = document.querySelectorAll('[style]');
      nodes.forEach(node => {
        var style = node.style;
        var strokeWidth = Math.trunc(Number.parseFloat(style.getPropertyValue('stroke-width')) * 10.0);
        style['stroke-width'] = `${strokeWidth}`;
      });
    }

    var mapBB = largestBB();
    setSvgWidthHeight(mapBB);
    cleanUpOutside(mapBB);

    // Mask is invalid in Kindle
    rmAll(document.querySelectorAll('mask'));
    // Symbol is invalid in Kindle
    rmAll(document.querySelectorAll('symbol'));
    // groups (g) is invalid in Kindle
    moveContentOutOfGroups();

    // Simplify the map to get the size down
    // Remove streams, rivers, etc.
    rmAll(document.querySelectorAll('[style*="rgb(74.499512%,90.99884%,100%)"]'));
    // Remove lighter topo lines
    rmAll(document.querySelectorAll('[style*="rgb(70.199585%,52.49939%,34.899902%)"]'));

    scaleStrokes();

    var result = {
      viewBox: document.rootElement.attributes["viewBox"].nodeValue,
      largestBB: `${mapBB.x} ${mapBB.y} ${mapBB.width} ${mapBB.height}`,
      svgTags: tagsInSvg(document.querySelectorAll("*")),
      clientBBs: clientBBs()
    };

    return result;
  });

  console.log(`Viewbox: ${names.viewBox}`);
  console.log(`Viewbox: ${names.largestBB}`);
  // await page.screenshot({path: 'example.png'});

  const svgContent = await page.content();

  fs.writeFile("processed.svg", svgContent, function(err) {
    if(err) {
        return console.log(err);
    }

    console.log("The file was saved!");
  });
  await browser.close();
})();
