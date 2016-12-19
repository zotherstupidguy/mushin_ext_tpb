// https://github.com/codemanki/cloudscraper forked at https://github.com/zotherstupidguy/cloudscraper

console.log("IUAM is active")

var url = process.argv[2]
console.log(url)

var cloudscraper = require('cloudscraper');

//cloudscraper.get('https://thepiratebay.org/s/?q=Algorithms&page=0&orderby=99', function(error, response, body) {
cloudscraper.get(url, function(error, response, body) {
  if (error) {
    console.log('Error occurred');
  } else {
    console.log(body);
    //console.log(body, response);
  }
});
