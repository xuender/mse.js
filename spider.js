
/*
set.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
 */
var Set;

Set = (function() {
  function Set(arr) {
    this.arr = arr != null ? arr : [];
  }

  Set.intersection = function(x, y) {
    var i, j, len, ret, t;
    ret = [];
    for (i = j = 0, len = x.length; j < len; i = ++j) {
      t = x[i];
      if (y[i]) {
        ret[i] = y[i] & t;
      }
    }
    return ret;
  };

  Set.equal = function(x, y) {
    var i, j, len, t;
    for (i = j = 0, len = x.length; j < len; i = ++j) {
      t = x[i];
      if (t && y[i]) {
        if (y[i] !== t) {
          return false;
        }
      } else if (t || y[i]) {
        return false;
      }
    }
    return true;
  };

  return Set;

})();


/*
spider.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
 */
var DATA, DICT, OLDS, STRS, URLS, addStr, count, read, secan,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

DICT = [];

URLS = [];

OLDS = [];

STRS = {};

DATA = {
  dict: [],
  urls: {}
};

addStr = function(s) {
  if (s in STRS) {
    return STRS[s]++;
  } else {
    return STRS[s] = 1;
  }
};

count = function(url, html) {
  var j, k, len, ref, results, s, v, w;
  console.info(url);
  w = /\w+/;
  ref = html.split(/\W+/);
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    s = ref[j];
    if (s && w.test(s)) {
      results.push((function() {
        var results1;
        results1 = [];
        for (k in STRS) {
          v = STRS[k];
          if (s === k) {
            DATA.urls[url] = v;
            break;
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    } else {
      results.push((function() {
        var results1;
        results1 = [];
        for (k in STRS) {
          v = STRS[k];
          if (s.indexOf(k) >= 0) {
            DATA.urls[url] = v;
            break;
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    }
  }
  return results;
};

read = function(html) {
  var d, j, l, len, len1, ref, s, w;
  w = /\w+/;
  for (j = 0, len = DICT.length; j < len; j++) {
    d = DICT[j];
    if (d && html.indexOf(d) >= 0) {
      addStr(d);
    }
  }
  ref = html.split(/\W+/);
  for (l = 0, len1 = ref.length; l < len1; l++) {
    s = ref[l];
    if (s && w.test(s)) {
      addStr(s.toLowerCase());
    }
  }
  return 1;
};

secan = function() {
  var div, h, url;
  if (URLS.length > 0) {
    url = $.trim(URLS.pop());
    if (url) {
      OLDS.push(url);
      $('#urls').val(OLDS.join('\n'));
      div = $('<div></div>');
      h = div.load(url, function(html) {
        read($(this).text());
        return $(this).contents('a').each(function(i, a) {
          var href;
          href = $(a).attr('href');
          if (href && (!(indexOf.call(href, ':') >= 0)) && (!(indexOf.call(URLS, href) >= 0)) && (!(indexOf.call(OLDS, href) >= 0))) {
            URLS.push(href);
            return secan();
          }
        });
      });
    }
    return secan();
  }
};

$(function() {
  $('#read').click(function() {
    return $.get($('#dict').val(), function(txt) {
      DICT = txt.split('\n');
      return $('#dict_size').text(DICT.length);
    });
  });
  $('#scan').click(function() {
    URLS = $('#urls').val().split('\n');
    if (DICT.length > 0 || confirm('Ignore CJK Dictionary?')) {
      OLDS = [];
      secan();
      return $('#count').attr("disabled", false);
    }
  });
  $('#count').click(function() {
    var d, div, h, i, j, k, l, len, len1, len2, m, ref, ref1, results, t, temp, url, v;
    $('#download').attr("disabled", false);
    temp = [];
    for (k in STRS) {
      v = STRS[k];
      temp.push({
        k: k,
        v: v
      });
    }
    DATA.dict = [];
    ref = temp.sort(function(a, b) {
      return b.v - a.v;
    });
    for (j = 0, len = ref.length; j < len; j++) {
      t = ref[j];
      DATA.dict.push(t.k);
    }
    ref1 = DATA.dict;
    for (i = l = 0, len1 = ref1.length; l < len1; i = ++l) {
      d = ref1[i];
      STRS[d] = i;
    }
    results = [];
    for (m = 0, len2 = OLDS.length; m < len2; m++) {
      url = OLDS[m];
      div = $("<div data-url=" + url + "></div>");
      results.push(h = div.load(url, function(html) {
        return count($(this).attr('data-url'), $(this).text());
      }));
    }
    return results;
  });
  return $('#download').click(function() {
    var a, evt;
    a = $("<a download='mse.json' href='data:text/plain," + (JSON.stringify(DATA)) + "'></a>");
    evt = document.createEvent("HTMLEvents");
    evt.initEvent("click", false, false);
    return a[0].dispatchEvent(evt);
  });
});
