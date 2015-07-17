
/*
set.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
 */
var Set,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Set = (function() {
  function Set(set) {
    this.set = set != null ? set : [];
    this["in"] = bind(this["in"], this);
    this.add = bind(this.add, this);
  }

  Set.prototype.add = function(arg) {
    var i, j, len, results, t;
    if (arg instanceof Array) {
      results = [];
      for (i = j = 0, len = arg.length; j < len; i = ++j) {
        t = arg[i];
        if (this.set[i]) {
          results.push(this.set[i] = this.set[i] | t);
        } else {
          results.push(this.set[i] = t);
        }
      }
      return results;
    } else {
      return this.add(Set.toArray(arg));
    }
  };

  Set.prototype["in"] = function(array) {
    var i, j, len, s, t;
    for (i = j = 0, len = array.length; j < len; i = ++j) {
      s = array[i];
      if (s) {
        t = s & this.set[i];
        if (t !== s) {
          return false;
        }
      }
    }
    return true;
  };

  Set.toArray = function(num) {
    var array, x, y;
    array = [];
    x = Math.floor(num / 32);
    y = 1 << (num % 32);
    if (array[x]) {
      array[x] = array[x] | y;
    } else {
      array[x] = y;
    }
    return array;
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

  return Set;

})();


/*
spider.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
 */
var DATA, DICT, IGNORED, KEYWORDS, OLDS, PAGES, TEMP, addPage, addStr, count, read, scan,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

DICT = [];

PAGES = [];

OLDS = [];

TEMP = [];

KEYWORDS = {};

DATA = {
  dict: [],
  pages: []
};

IGNORED = ['be', 'a', 'to', 'for', 'the', 'an', 'of', 'then'];

addStr = function(s) {
  if (s in KEYWORDS) {
    return KEYWORDS[s]++;
  } else {
    return KEYWORDS[s] = 1;
  }
};

count = function(url, title, html) {
  var j, k, l, len, len1, notInPage, notInPages, p, page, ref, ref1, s, v, w;
  w = /\w+/;
  page = {
    url: url,
    title: title,
    set: new Set()
  };
  notInPages = true;
  ref = DATA.pages;
  for (j = 0, len = ref.length; j < len; j++) {
    p = ref[j];
    if (p.url === url) {
      page = p;
      notInPage = false;
    }
  }
  ref1 = html.split(/\W+/);
  for (l = 0, len1 = ref1.length; l < len1; l++) {
    s = ref1[l];
    if (s && w.test(s)) {
      for (k in KEYWORDS) {
        v = KEYWORDS[k];
        if (s === k) {
          page.set.add(v);
          break;
        }
      }
    }
  }
  for (k in KEYWORDS) {
    v = KEYWORDS[k];
    if (html.indexOf(k) >= 0) {
      page.set.add(v);
    }
  }
  if (notInPages) {
    DATA.pages.push(page);
  }
  return console.info('count:', url);
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

addPage = function(url) {
  var j, l, len, len1, len2, m, p;
  if (indexOf.call(url, ':') >= 0) {
    return;
  }
  for (j = 0, len = TEMP.length; j < len; j++) {
    p = TEMP[j];
    if (url === p.url) {
      return;
    }
  }
  for (l = 0, len1 = OLDS.length; l < len1; l++) {
    p = OLDS[l];
    if (url === p.url) {
      return;
    }
  }
  for (m = 0, len2 = PAGES.length; m < len2; m++) {
    p = PAGES[m];
    if (url === p.url) {
      return;
    }
  }
  return PAGES.push({
    url: url,
    title: ''
  });
};

scan = function(find) {
  var div, h, page;
  if (find == null) {
    find = true;
  }
  if (PAGES.length > 0) {
    page = PAGES.pop();
    if (page.url) {
      TEMP.push(page);
      div = $("<div></div>");
      div.data('page', page);
      h = div.load(page.url, function(html, status) {
        if (status !== 'success') {
          return;
        }
        $(this).find('script').remove();
        read($(this).text());
        page = $(this).data('page');
        console.info('read:', page.url);
        page['title'] = $(this).find('title').text();
        if (page) {
          OLDS.push(page);
          $('#pages').val(JSON.stringify(OLDS));
        }
        if (!find) {
          return;
        }
        return $(this).find('a').each(function(i, a) {
          var al, href;
          al = $(a);
          href = Mini.getUrl(page.url, al.attr('href'));
          if (href) {
            addPage(href);
            return scan(find);
          }
        });
      });
    }
    return scan(find);
  }
};

$(function() {
  $('#load').click(function() {
    return $.get($('#dict').val(), function(txt) {
      DICT = txt.split('\n');
      return $('#dict_size').text(DICT.length);
    });
  });
  $('#scan').click(function() {
    PAGES = JSON.parse($('#pages').val());
    if (DICT.length > 0 || confirm('Ignore CJK Dictionary?')) {
      OLDS = [];
      TEMP = [];
      scan();
      $('#count').attr("disabled", false);
      return $('#rescan').attr("disabled", false);
    }
  });
  $('#rescan').click(function() {
    OLDS = [];
    TEMP = [];
    PAGES = JSON.parse($('#pages').val());
    KEYWORDS = {};
    return scan(false);
  });
  $('#count').click(function() {
    var j, k, len, ref, ref1, t, temp, v;
    temp = [];
    for (k in KEYWORDS) {
      v = KEYWORDS[k];
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
      if (ref1 = t.k, indexOf.call(IGNORED, ref1) < 0) {
        DATA.dict.push(t.k);
      }
    }
    $('#keywords').val(JSON.stringify(DATA.dict));
    return $('#builder').attr("disabled", false);
  });
  $('#builder').click(function() {
    var d, div, h, i, j, l, len, len1, p, ref;
    ref = DATA.dict;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      d = ref[i];
      KEYWORDS[d] = i;
    }
    for (l = 0, len1 = OLDS.length; l < len1; l++) {
      p = OLDS[l];
      div = $("<div></div>");
      div.data('page', p);
      h = div.load(p.url, function(html) {
        var page;
        $(this).find('script').remove();
        page = $(this).data('page');
        return count(page.url, page.title, $(this).text());
      });
    }
    return $('#download').attr("disabled", false);
  });
  return $('#download').click(function() {
    var a, d, evt, j, len, ref;
    ref = DATA.pages;
    for (j = 0, len = ref.length; j < len; j++) {
      d = ref[j];
      d['set'] = d['set']['set'];
    }
    a = $("<a download='mse.json' href='data:text/plain," + (JSON.stringify(DATA)) + "'></a>");
    evt = document.createEvent("HTMLEvents");
    evt.initEvent("click", false, false);
    return a[0].dispatchEvent(evt);
  });
});
