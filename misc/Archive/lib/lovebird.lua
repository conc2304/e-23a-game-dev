LJ1  +   C  =  +  7   C  =  G   �  
print�  ;+   4 + 7+  7+  7> = :  +   +  +  7  7>:: +   7     7  '  > +   4	 : +   7 
    T�4 	 1 5	 0  �4  +  7> D�+  7+  7 % %	 
 $	
	>9BN�+   ) : G  � �initedpages.lovebird, reqtemplate
pages
pairs wrapprint
printorigprintsettimeoutgetsockname	addr	port	host	bindassertserver3   4  7%   @  echo(%q)formatstring.  4  7+    >G   �insert
tableb  2   1  +   C  =4 7+ 7  4 > 0  �?  �  tostringmapconcat
table � "  T�%   $ T�% 1 %   % $ 7%  >  %  %   $ 4	 +  7
   > = 1 0  �H � loadstringassert = ...local echo %?>(.-)<%?lua	gsub
<?lua?> ,= 
  2  4    >D� 	 >9BN�H 
pairs� %   4 7+  72 C  <  4 >% >$  4   >+  7  T�+  7  >G  �wrapprint
print tostringmapconcat
table[lovebird] ����?   4  74 %   $> ?  0xtonumber	charstringM  1    7 % % > 7%  >0  �H %%(..) %+	gsub � 
 2    7 % >:: 2  :7 7% >T�7+  7	 >9AN�H �unescape([^&^?]-)=([^&^#]*)gmatch
query/([^%?]*)%??(.*)
matchsearch	path'     7  % % @ 	&lt;<	gsub@     T�H    7  '  >% $H ...sub�   #4    >4   >  T�  T�  T�) T�) H ) H T�  T�) H 4   >4  >  T�) T�) H tostringtonumber� 
 $+  7   T�) H 4 +  7 >D�%  7%	 %
 > 7%	 %
 >% $  7	 	 >  T�) H BN�) H �
match$	%%d*%*%%.%.	gsub^
pairswhitelist3   +   2  :  +   % : G  �buffer
lines� 	 4 7 >:  ' : 4 7+  7  >+  7 +  7 T�4 7+  7' >+  7>G  �recalcbufferremovemaxlines
linesinsert
table
countos	time�  67  +  7  T
�+  77  > 7% % > 7  T�%  %	 $T�7 
 T�%  $%  %	 $7 '  T�% 7 %  $+  7  T�4 7% 7 > $H   	time-<span class="timestamp">%H:%M:%S</span> 	dateostimestamp</span> <span class="repeatcount">
count<span class="errorline">(<span class="errormarker">!</span> 
error</span><span class="inputline">
input	type	<br>
	gsubhtmlescapeallowhtmlstre  1   +  4 7+  7+  7  >% >:G  �	<br>
linesmapconcat
tablebuffer � 42   ' 4  % C  =' I�4 7  4 4  	 C
  = =  =K�4 7  % >+  7+  7 6  T�7 T�4
 7	>:	7 :+  7>T�+  73 :>G  � 	typeoutputpushlinerecalcbuffer
countos	timestr
lines concattostringinsert
table#select�  +  7 3 : >+  7  T�+  7%   $>G  �[lovebird] ERROR: origprintwrapprintstr 	type
errorpushline{   +   7   + 6  +  + > % %   % %   $, G    � ��
Content-Length: HTTP/1.1 200 OK

pages�	 7  7 T�  T�% +  76  T�% 0 �)  4 1 +  7>0  �H H �onerror xpcall0HTTP/1.1 404
Content-Length: 8

Bad page
pages
index	pathparsedurl   Q�  7   >  T� T�4 7) >T�4 7)  >T�H T�G  
yieldcoroutinetimeoutreceive�   '   T�Q�  7    >  T� T�4 7)  >T�4 7) >T�G  
yieldcoroutineclosed	send� [%  2  :   7 >::+  7  % >:7 7 >:
:	:2  :Q�+  7  % >  T� 	  T�T� 7% >79T�77  T�+  7  77>:2  :7  T�7 7% >T�7+	  7		
 >	9	AN�+  77	>:+  7 >+  7   >  7 >G  �
close	sendonrequestparseurlparsedurlunescape([^&]-)=([^&^#]*)gmatchparsedbody	bodyContent-Length(.-):%s*(.*)$headers
match
protourlmethod*lreceiverequestgetsockname	port	addrsocket(%S*)%s*(%S*)%s*(%S*) )   +   7   + > G     onconnect     G  (  4   1 1 > G     �  xpcall�  ?+   7      T �+   7  > Q '�+   7    7  >    T�0 �  7 '  >  7 >+  7 >  T	�4 71	 >+  7
) 9T�+  7%  >  7 >0 �4  +  7
> D� >  T�+  7
)  9BN�G  �
pairs
close-got non-whitelisted connection attempt: 
traceconnections 	wrapcoroutinecheckwhitelistgetsocknamesettimeoutacceptserver	initinited�\  CX4   % > 3 4   T�4 :) :% :%	 :2  :
2  :2  :) :) :) :) :'@:3 :'� :(  :7% :7% :7% :1 :1 :1  :1" :!1$ :#1& :%1( :'1* :)1, :+1. :-10 :/12 :114 :316 :518 :71: :91< :;1> :=1@ :?1B :A0  �H  update onconnect 	send receive onrequest onerror 
print recalcbuffer pushline 
clear checkwhitelist compare truncate htmlescape parseurl unescape 
trace map template 	init�<?lua
  local t = _G
  local p = req.parsedurl.query.p or ""
  p = p:gsub("%.+", "."):match("^[%.]*(.*)[%.]*$")
  if p ~= "" then
    for x in p:gmatch("[^%.]+") do
      t = t[x] or t[tonumber(x)]
      -- Return early if path does not exist
      if type(t) ~= "table" then
        echo('{ "valid": false, "path": ' .. string.format("%q", p) .. ' }')
        return
      end
    end
  end
?>
{
  "valid": true,
  "path": "<?lua echo(p) ?>",
  "vars": [
    <?lua
      local keys = {}
      for k in pairs(t) do
        if type(k) == "number" or type(k) == "string" then
          table.insert(keys, k)
        end
      end
      table.sort(keys, lovebird.compare)
      for _, k in pairs(keys) do
        local v = t[k]
    ?>
      {
        "key": "<?lua echo(k) ?>",
        "value": <?lua echo(
                          string.format("%q",
                            lovebird.truncate(
                              lovebird.htmlescape(
                                tostring(v)), 26))) ?>,
        "type": "<?lua echo(type(v)) ?>",
      },
    <?lua end ?>
  ]
}
env.json% <?lua echo(lovebird.buffer) ?> �M<?lua
-- Handle console input
if req.parsedbody.input then
  local str = req.parsedbody.input
  if lovebird.echoinput then
    lovebird.pushline({ type = 'input', str = str })
  end
  if str:find("^=") then
    str = "print(" .. str:sub(2) .. ")"
  end
  xpcall(function() assert(lovebird.loadstring(str, "input"))() end,
         lovebird.onerror)
end
?>

<!doctype html>
<html>
  <head>
  <meta http-equiv="x-ua-compatible" content="IE=Edge"/>
  <title>lovebird</title>
  <style>
    body {
      margin: 0px;
      font-size: 14px;
      font-family: helvetica, verdana, sans;
      background: #FFFFFF;
    }
    form {
      margin-bottom: 0px;
    }
    .timestamp {
      color: #909090;
      padding-right: 4px;
    }
    .repeatcount {
      color: #F0F0F0;
      background: #505050;
      font-size: 11px;
      font-weight: bold;
      text-align: center;
      padding-left: 4px;
      padding-right: 4px;
      padding-top: 0px;
      padding-bottom: 0px;
      border-radius: 7px;
      display: inline-block;
    }
    .errormarker {
      color: #F0F0F0;
      background: #8E0000;
      font-size: 11px;
      font-weight: bold;
      text-align: center;
      border-radius: 8px;
      width: 17px;
      padding-top: 0px;
      padding-bottom: 0px;
      display: inline-block;
    }
    .greybordered {
      margin: 12px;
      background: #F0F0F0;
      border: 1px solid #E0E0E0;
      border-radius: 3px;
    }
    .inputline {
      font-family: mono, courier;
      font-size: 13px;
      color: #606060;
    }
    .inputline:before {
      content: '\00B7\00B7\00B7';
      padding-right: 5px;
    }
    .errorline {
      color: #8E0000;
    }
    #header {
      background: #101010;
      height: 25px;
      color: #F0F0F0;
      padding: 9px
    }
    #title {
      float: left;
      font-size: 20px;
    }
    #title a {
      color: #F0F0F0;
      text-decoration: none;
    }
    #title a:hover {
      color: #FFFFFF;
    }
    #version {
      font-size: 10px;
    }
    #status {
      float: right;
      font-size: 14px;
      padding-top: 4px;
    }
    #main a {
      color: #000000;
      text-decoration: none;
      background: #E0E0E0;
      border: 1px solid #D0D0D0;
      border-radius: 3px;
      padding-left: 2px;
      padding-right: 2px;
      display: inline-block;
    }
    #main a:hover {
      background: #D0D0D0;
      border: 1px solid #C0C0C0;
    }
    #console {
      position: absolute;
      top: 40px; bottom: 0px; left: 0px; right: 312px;
    }
    #input {
      position: absolute;
      margin: 10px;
      bottom: 0px; left: 0px; right: 0px;
    }
    #inputbox {
      width: 100%;
      font-family: mono, courier;
      font-size: 13px;
    }
    #output {
      overflow-y: scroll;
      position: absolute;
      margin: 10px;
      line-height: 17px;
      top: 0px; bottom: 36px; left: 0px; right: 0px;
    }
    #env {
      position: absolute;
      top: 40px; bottom: 0px; right: 0px;
      width: 300px;
    }
    #envheader {
      padding: 5px;
      background: #E0E0E0;
    }
    #envvars {
      position: absolute;
      left: 0px; right: 0px; top: 25px; bottom: 0px;
      margin: 10px;
      overflow-y: scroll;
      font-size: 12px;
    }
  </style>
  </head>
  <body>
    <div id="header">
      <div id="title">
        <a href="https://github.com/rxi/lovebird">lovebird</a>
        <span id="version"><?lua echo(lovebird._version) ?></span>
      </div>
      <div id="status"></div>
    </div>
    <div id="main">
      <div id="console" class="greybordered">
        <div id="output"> <?lua echo(lovebird.buffer) ?> </div>
        <div id="input">
          <form method="post"
                onkeydown="return onInputKeyDown(event);"
                onsubmit="onInputSubmit(); return false;">
            <input id="inputbox" name="input" type="text"
                autocomplete="off"></input>
          </form>
        </div>
      </div>
      <div id="env" class="greybordered">
        <div id="envheader"></div>
        <div id="envvars"></div>
      </div>
    </div>
    <script>
      document.getElementById("inputbox").focus();

      var changeFavicon = function(href) {
        var old = document.getElementById("favicon");
        if (old) document.head.removeChild(old);
        var link = document.createElement("link");
        link.id = "favicon";
        link.rel = "shortcut icon";
        link.href = href;
        document.head.appendChild(link);
      }

      var truncate = function(str, len) {
        if (str.length <= len) return str;
        return str.substring(0, len - 3) + "...";
      }

      var geturl = function(url, onComplete, onFail) {
        var req = new XMLHttpRequest();
        req.onreadystatechange = function() {
          if (req.readyState != 4) return;
          if (req.status == 200) {
            if (onComplete) onComplete(req.responseText);
          } else {
            if (onFail) onFail(req.responseText);
          }
        }
        url += (url.indexOf("?") > -1 ? "&_=" : "?_=") + Math.random();
        req.open("GET", url, true);
        req.send();
      }

      var divContentCache = {}
      var updateDivContent = function(id, content) {
        if (divContentCache[id] != content) {
          document.getElementById(id).innerHTML = content;
          divContentCache[id] = content
          return true;
        }
        return false;
      }

      var onInputSubmit = function() {
        var b = document.getElementById("inputbox");
        var req = new XMLHttpRequest();
        req.open("POST", "/", true);
        req.send("input=" + encodeURIComponent(b.value));
        /* Do input history */
        if (b.value && inputHistory[0] != b.value) {
          inputHistory.unshift(b.value);
        }
        inputHistory.index = -1;
        /* Reset */
        b.value = "";
        refreshOutput();
      }

      /* Input box history */
      var inputHistory = [];
      inputHistory.index = 0;
      var onInputKeyDown = function(e) {
        var key = e.which || e.keyCode;
        if (key != 38 && key != 40) return true;
        var b = document.getElementById("inputbox");
        if (key == 38 && inputHistory.index < inputHistory.length - 1) {
          /* Up key */
          inputHistory.index++;
        }
        if (key == 40 && inputHistory.index >= 0) {
          /* Down key */
          inputHistory.index--;
        }
        b.value = inputHistory[inputHistory.index] || "";
        b.selectionStart = b.value.length;
        return false;
      }

      /* Output buffer and status */
      var refreshOutput = function() {
        geturl("/buffer", function(text) {
          updateDivContent("status", "connected &#9679;");
          if (updateDivContent("output", text)) {
            var div = document.getElementById("output");
            div.scrollTop = div.scrollHeight;
          }
          /* Update favicon */
          changeFavicon("data:image/png;base64," +
"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAP1BMVEUAAAAAAAAAAAD////19fUO"+
"Dg7v7+/h4eGzs7MlJSUeHh7n5+fY2NjJycnGxsa3t7eioqKfn5+QkJCHh4d+fn7zU+b5AAAAAnRS"+
"TlPlAFWaypEAAABRSURBVBjTfc9HDoAwDERRQ+w0ern/WQkZaUBC4e/mrWzppH9VJjbjZg1Ii2rM"+
"DyR1JZ8J0dVWggIGggcEwgbYCRbuPRqgyjHNpzUP+39GPu9fgloC5L9DO0sAAAAASUVORK5CYII="
          );
        },
        function(text) {
          updateDivContent("status", "disconnected &#9675;");
          /* Update favicon */
          changeFavicon("data:image/png;base64," +
"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAYFBMVEUAAAAAAAAAAADZ2dm4uLgM"+
"DAz29vbz8/Pv7+/h4eHIyMiwsLBtbW0lJSUeHh4QEBDn5+fS0tLDw8O0tLSioqKfn5+QkJCHh4d+"+
"fn5ycnJmZmZgYGBXV1dLS0tFRUUGBgZ0He44AAAAAnRSTlPlAFWaypEAAABeSURBVBjTfY9HDoAw"+
"DAQD6Z3ey/9/iXMxkVDYw0g7F3tJReosUKHnwY4pCM+EtOEVXrb7wVRA0dMbaAcUwiVeDQq1Jp4a"+
"xUg5kE0ooqZu68Di2Tgbs/DiY/9jyGf+AyFKBAK7KD2TAAAAAElFTkSuQmCC"
          );
        });
      }
      setInterval(refreshOutput,
                  <?lua echo(lovebird.updateinterval) ?> * 1000);

      /* Environment variable view */
      var envPath = "";
      var refreshEnv = function() {
        geturl("/env.json?p=" + envPath, function(text) {
          var json = eval("(" + text + ")");

          /* Header */
          var html = "<a href='#' onclick=\"setEnvPath('')\">env</a>";
          var acc = "";
          var p = json.path != "" ? json.path.split(".") : [];
          for (var i = 0; i < p.length; i++) {
            acc += "." + p[i];
            html += " <a href='#' onclick=\"setEnvPath('" + acc + "')\">" +
                    truncate(p[i], 10) + "</a>";
          }
          updateDivContent("envheader", html);

          /* Handle invalid table path */
          if (!json.valid) {
            updateDivContent("envvars", "Bad path");
            return;
          }

          /* Variables */
          var html = "<table>";
          for (var i = 0; json.vars[i]; i++) {
            var x = json.vars[i];
            var fullpath = (json.path + "." + x.key).replace(/^\./, "");
            var k = truncate(x.key, 15);
            if (x.type == "table") {
              k = "<a href='#' onclick=\"setEnvPath('" + fullpath + "')\">" +
                  k + "</a>";
            }
            var v = "<a href='#' onclick=\"insertVar('" +
                    fullpath.replace(/\.(-?[0-9]+)/g, "[$1]") +
                    "');\">" + x.value + "</a>"
            html += "<tr><td>" + k + "</td><td>" + v + "</td></tr>";
          }
          html += "</table>";
          updateDivContent("envvars", html);
        });
      }
      var setEnvPath = function(p) {
        envPath = p;
        refreshEnv();
      }
      var insertVar = function(p) {
        var b = document.getElementById("inputbox");
        b.value += p;
        b.focus();
      }
      setInterval(refreshEnv, <?lua echo(lovebird.updateinterval) ?> * 1000);
    </script>
  </body>
</html>

indexupdateintervalmaxlines  127.0.0.1whitelist	portechoinputallowhtmltimestampwrapprint
pagesconnections
linesbuffer*	hostinited	loadloadstring _version
0.4.1socketrequire���� 