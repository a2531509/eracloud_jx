function showCurrentPdf(a){odefaultwindow(a,"/jsp/reportMain/reportMain.jsp")}function showReport(a,b,c){odefaultwindow(a,"/jsp/reportMain/innerreportMain.jsp?actionNo="+b,c)}
function odefaultwindow(a,b,c){document.getElementsByTagName("body")[0].style.overflow="hidden";var d,e;window.attachEvent&&navigator.userAgent.indexOf("Opera");d=document.documentElement.clientWidth;e=document.documentElement.clientHeight;var g=document.createElement("div");g.setAttribute("id","_yx_yx");g.style.zIndex=1E4;g.style.display="block";g.style.filter="alpha(opacity=80)";g.style.opacity=.8;g.style.backgroundColor="#000000";g.style.position="absolute";g.style.textAlign="center";g.style.left=
"0px";g.style.top="0px";g.style.width=d+"px";g.style.height=e+"px";g.style.borderRadius="1px";var f=document.createElement("div");f.setAttribute("id","_yx_header");f.style.zIndex=10002;f.style.backgroundColor="gray";f.style.width=d-20+"px";f.style.height="34px";f.style.marginLeft="auto";f.style.marginRight="auto";f.style.marginTop="0px";f.style.marginButtom="0px";f.style.left="10px";f.style.top="10px";f.style.position="absolute";var h=document.createElement("table");h.style.width="100%";h.style.height=
"100%";h.style.border="0";h.style.margin="0px";h.style.padding="0px";h.setAttribute("frame","void");h.setAttribute("cellpadding","0");h.setAttribute("cellspacing","0");h.style.zIndex=10002;var k=document.createElement("tbody"),m=document.createElement("tr"),l=document.createElement("td");l.style.textAlign="left";l.style.fontSize="18px";l.style.color="#FFF";l.style.fontFamily="\u5fae\u8f6f\u96c5\u9ed1";l.style.fontWeight="700";l.style.padding="0px";l.style.margin="0px";l.style.paddingLeft="5px";a=
document.createTextNode(a);l.appendChild(a);a=document.createElement("td");a.style.textAlign="right";var p=document.createElement("img");p.setAttribute("src","/images/g_close.gif");p.onclick=function(){"function"==typeof c&&c();closeCRH()};p.style.cursor="pointer";a.appendChild(p);a.style.margin="0px";a.style.padding="0px";a.style.paddingRight="5px";m.appendChild(l);m.appendChild(a);k.appendChild(m);h.appendChild(k);f.appendChild(h);h=document.createElement("div");h.setAttribute("id","_yx_yx_msg");
h.style.zIndex=10002;h.style.marginLeft="0px";h.style.marginRight="0px";h.style.marginTop="auto";h.style.marginButtom="auto";h.style.width=d-20+"px";h.style.height=e-20-34+"px";h.style.verticalAlign="middle";h.style.overflow="hidden";h.style.backgroundColor="#FFFFFF";h.style.position="absolute";h.style.backgroundImage="url(/images/xubox_loading2.gif)";h.style.backgroundRepeat="no-repeat";h.style.backgroundPosition="center";var n=document.createElement("iframe");n.setAttribute("id","_s_sgbs_df");n.style.display=
"none";n.setAttribute("src",b);window.attachEvent&&-1==navigator.userAgent.indexOf("Opera")?n.onreadystatechange=function(){"complete"==n.readyState&&(document.getElementById("_yx_yx_msg").style.backgroundImage="",document.getElementById("_s_sgbs_df").style.display="block")}:n.onload=function(){document.getElementById("_yx_yx_msg").style.backgroundImage="";document.getElementById("_s_sgbs_df").style.display="block"};n.setAttribute("border","0");n.style.width="100%";n.style.height="100%";n.style.margin=
"0px";n.style.padding="0px";n.setAttribute("frameborder","no");h.appendChild(n);h.style.left="10px";h.style.top="44px";document.body.appendChild(f);document.body.appendChild(h);document.body.appendChild(g);var q=window.onresize;window.onresize=function(){q&&q();document.getElementById("_yx_yx")&&"block"==document.getElementById("_yx_yx").style.display&&(document.getElementById("_yx_yx").style.width=document.documentElement.clientWidth+"px",document.getElementById("_yx_yx").style.height=document.documentElement.clientHeight+
"px",document.getElementById("_yx_yx_msg").style.width=document.documentElement.clientWidth-20+"px",document.getElementById("_yx_yx_msg").style.height=document.documentElement.clientHeight-20-34+"px",document.getElementById("_yx_header").style.width=document.documentElement.clientWidth-20+"px",document.getElementById("_yx_header").style.left="10px")}}
function closeCRH(){document.getElementById("_yx_yx")&&(document.body.removeChild(document.getElementById("_yx_yx")),document.body.removeChild(document.getElementById("_yx_yx_msg")),document.body.removeChild(document.getElementById("_yx_header")),document.getElementsByTagName("body")[0].style.overflow="visible")}$(document).keydown(function(a){var b;8==a.keyCode?(b=a.srcElement||a.target,b="INPUT"==b.tagName.toUpperCase()||"TEXTAREA"==b.tagName.toUpperCase()?b.readOnly||b.disabled:!0):b=!1;b&&a.preventDefault()});
function showLayer(a){"undefined"==typeof a&&document.getElementById("_ab_yxx_yx_o")?a=!1:"undefined"!=typeof a||document.getElementById("_ab_yxx_yx_o")||(a=!0);if(a&&!document.getElementById("_ab_yxx_yx_o")){a=document.createElement("div");a.setAttribute("id","_ab_yxx_yx_o");a.style.zIndex=1E3;a.style.display="none";a.style.position="absolute";a.style.left="0px";a.style.top="0px";a.style.filter="alpha(opacity=10)";a.style.opacity=.1;a.style.backgroundColor="#000000";a.style.width=document.body.offsetWidth+
"px";a.style.height=document.body.offsetHeight+"px";var b=document.createElement("div");b.setAttribute("id","_ab_yxx_yx_o_msg");b.style.zIndex=1003;b.style.marginLeft="0px;";b.style.marginRight="0px";b.style.marginTop="auto";b.style.marginButtom="auto";b.style.width="32px";b.style.height="32px";b.style.display="none";b.style.position="fixed";b.style.verticalAlign="middle";b.style.lineHeight="32px";b.style.backgroundRepeat="no-repeat";var c=document.createElement("img");c.setAttribute("src","/images/xubox_loading2.gif");
b.appendChild(c);b.style.left=(document.documentElement.clientWidth-32)/2+"px";b.style.top=(document.documentElement.clientHeight-32)/2+"px";document.body.appendChild(a);document.body.appendChild(b);a.style.display="block";b.style.display="block";var d=window.onresize;window.onresize=function(){d&&d();document.getElementById("_ab_yxx_yx_o_msg")&&"block"==document.getElementById("_ab_yxx_yx_o_msg").style.display&&(document.getElementById("_ab_yxx_yx_o").style.width=document.body.offsetWidth+"px",document.getElementById("_ab_yxx_yx_o").style.height=
document.body.offsetHeight+"px",document.getElementById("_ab_yxx_yx_o_msg").style.left=(document.documentElement.clientWidth-32)/2+"px",document.getElementById("_ab_yxx_yx_o_msg").style.top=(document.documentElement.clientHeight-32)/2+"px")}}else a&&document.getElementById("_ab_yxx_yx_o")&&"block"!=document.getElementById("_ab_yxx_yx_o").style.display?(document.getElementById("_ab_yxx_yx_o").style.display="block",document.getElementById("_ab_yxx_yx_o_msg").style.display="block"):!a&&document.getElementById("_ab_yxx_yx_o")&&
(document.body.removeChild(document.getElementById("_ab_yxx_yx_o")),document.body.removeChild(document.getElementById("_ab_yxx_yx_o_msg")))}Number.prototype.mul100=function(){return(100*this).toFixed(0)};Number.prototype.div100=function(){return(this/100).toFixed(2)};String.prototype.nsubstr=function(a,b){return this.substring(a,a+b)};String.prototype.trim=function(){return this.replace(/(^\s*)|(\s*$)/g,"")};
String.prototype.byteLen=function(){var a=0,b=this.length;if(0<b){for(var c=0;c<b;c++)255<this.charCodeAt(c)?a+=2:a++;return a}return 0};function getDatabaseDate(){var a="";dwr.engine.setAsync(!1);commonDwr.getDatabaseDate(function(b){a=b});dwr.engine.setAsync(!0);return a}function dealNull(a){return null==a||"undefined"==typeof a||void 0==typeof a||"undefined"==a||void 0==a?"":"string"==typeof a?a.replace(/\s/g,""):a}
function createCertType(a,b){var c;try{c=$("#"+a).combobox({width:174,url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CERT_TYPE",valueField:"codeValue",editable:!1,textField:"codeName",panelHeight:"auto",onSelect:function(c){"function"==typeof b?b():$("#"+a).val(c.codeValue)}});var d=document.getElementById(a).onclick;d?document.getElementById(a).onclick=function(){d();$("#"+a).combobox("hidePanel");$("#"+a).combobox("showPanel")}:document.getElementById(a).onclick=function(){$("#"+
a).combobox("hidePanel");$("#"+a).combobox("showPanel")};return c}catch(e){defaultCatchErrMsg(e)}}
function createSysOrg(a,b,c,d,e,g){try{var f="",h=!0,k="",m="";if("string"==typeof a)f=a;else if("object"==typeof a)f=a.id;else return;if(""!=dealNull(f)&&"string"==typeof f){"string"==typeof b?k=b:"object"==typeof b&&(k=b.id);"string"==typeof c?m=c:"object"==typeof c&&(m=c.id);var l={url:"commAction!findAllSysOrg.action",editable:!1,method:"post",panelHeight:"auto",checkbox:!1,cascadeCheck:!1,panelMaxHeight:200,panelMinWidth:174,queryParams:{isJudgePermission:!0},cache:!0,lines:!0,animate:!0,loadFilter:function(a){"0"!=
a.status&&($.messager.alert("\u7cfb\u7edf\u6d88\u606f",a.msg,"warning"),$("#"+f).combotree("disable"));return a.rows},onSelect:function(a){""!=dealNull(k)&&"string"==typeof k&&($("#"+k).combotree("clear"),$("#"+k).combotree("reload","commAction!findAllSysBranch.action?isShowOrg=0&orgId="+a.id))},onLoadSuccess:function(a,b){if(b&&0<b.length){var c=$("#"+f).combotree("getValue");""==dealNull(c)&&(c=b[0].id);""!=c&&"erp2_erp2"!=c&&1==b.length?$("#"+f).combotree("readonly",!0):$("#"+f).combobox("readonly",
!1);var d=$("#"+f).combotree("options");"boolean"==typeof d.isReadOnly&&d.isReadOnly&&$("#"+f).combotree("readonly",!0);$("#"+f).combotree("setValue",c);""!=dealNull(k)&&"string"==typeof k&&($("#"+k).combotree("clear"),$("#"+k).combotree("reload","commAction!findAllSysBranch.action?isShowOrg=0&orgId="+c))}}};"object"==typeof a&&($.extend(l,a),"boolean"==typeof a.isJudgePermission&&(h=a.isJudgePermission));"object"==typeof d&&($.extend(l,d),"boolean"==typeof d.isJudgePermission&&(h=d.isJudgePermission));
$.extend(l,{queryParams:{isJudgePermission:h}});$("#"+f).combotree(l);""!=dealNull(k)&&"string"==typeof k&&(a={url:"commAction!findAllSysBranch.action?isShowOrg=0"},d={},"object"==typeof b&&$.extend(a,b),"object"==typeof e&&$.extend(a,e),"object"==typeof c&&$.extend(d,c),"object"==typeof g&&$.extend(d,g),$.extend(a,{isJudgePermission:h}),createSysBranch(k,m,a,d))}}catch(p){defaultCatchErrMsg(p)}}
function createSys_Org(a,b,c){try{a=$.extend({id:""},a),b=$.extend({id:""},b),c=$.extend({id:""},c),"object"==typeof a&&""!=dealNull(a.id)&&createSysOrg(a.id,b.id,c.id,a,b,c)}catch(d){defaultCatchErrMsg(d)}}
function createSysBranch(a,b,c,d){try{var e=!0,g="",f="";if("string"==typeof a)g=a;else if("object"==typeof a)g=a.id;else return;if(""!=dealNull(g)&&"string"==typeof g){"string"==typeof b?f=b:"object"==typeof b&&(f=b.id);var f=dealNull(f),h={url:"commAction!findAllSysBranch.action",editable:!1,method:"post",panelHeight:"auto",panelMaxHeight:200,panelMinWidth:274,panelMaxWidth:274,queryParams:{isJudgePermission:!0},width:"auto",checkbox:!1,cascadeCheck:!1,cache:!0,lines:!0,animate:!0,loadFilter:function(a){"0"!=
a.status&&($.messager.alert("\u7cfb\u7edf\u6d88\u606f",a.msg,"warning"),$("#"+g).combotree("disable"));return a.rows},onSelect:function(a){""!=dealNull(f)&&"string"==typeof f&&($("#"+f).combobox("clear"),$("#"+f).combobox("reload","commAction!getAllOperators.action?branch_Id="+a.id))},onLoadSuccess:function(a,b){if(b&&0<b.length){var c=$("#"+g).combotree("getValue");"erp2_erp2"==c&&(c="");""==dealNull(c)&&(c=b[0].id);""!=c&&"erp2_erp2"!=c&&1==b.length?$("#"+g).combotree("readonly",!0):$("#"+g).combobox("readonly",
!1);var d=$("#"+g).combotree("options");"boolean"==typeof d.isReadOnly&&1==d.isReadOnly&&$("#"+g).combotree("readonly",!0);$("#"+g).combotree("setValue",c);""!=dealNull(f)&&"string"==typeof f&&($("#"+f).combobox("clear"),$("#"+f).combobox("reload","commAction!getAllOperators.action?branch_Id="+c))}}};"object"==typeof a&&$.extend(h,a);"object"==typeof c&&$.extend(h,c);"boolean"==typeof h.isJudgePermission&&(e=h.isJudgePermission);$.extend(h,{queryParams:{isJudgePermission:e}});$("#"+g).combotree(h);
""!=dealNull(f)&&"string"==typeof f&&(a={url:"commAction!getAllOperators.action",editable:!1,cache:!1,panelHeight:"auto",panelMaxHeight:200,panelMinWidth:174,queryParams:{isJudgePermission:!0},valueField:"user_Id",textField:"user_Name",onLoadSuccess:function(a){if(a&&0<a.length){a=$("#"+f).val();"erp2_erp2"==a&&(a="");var b=$("#"+f).combobox("getData");""==dealNull(a)&&b&&0<b.length&&(a=b[0].user_Id);""!=a&&"erp2_erp2"!=a&&1==b.length?$("#"+f).combobox("readonly",!0):$("#"+f).combobox("readonly",
!1);b=$("#"+f).combobox("options");"boolean"==typeof b.isReadOnly&&b.isReadOnly&&$("#"+f).combobox("readonly",!0);$("#"+f).combobox("setValue",a)}}},"object"==typeof b&&$.extend(a,b),"object"==typeof d&&$.extend(a,d),$.extend(a,{queryParams:{isJudgePermission:e}}),$("#"+f).combobox(a))}}catch(k){defaultCatchErrMsg(k)}}
function createLocalDataSelect(a,b){try{var c="";"string"==typeof a?c=a:"object"==typeof a&&(c=a.id);if(""!=dealNull(c)){var d={width:174,valueField:"value",editable:!1,value:"",panelMaxHeight:200,panelMinWidth:174,textField:"text",panelHeight:"auto"};"object"==typeof a&&(d=$.extend(d,a,{url:""}));"object"==typeof b&&(d=$.extend(d,b,{url:""}));return $("#"+c).combobox(d)}}catch(e){defaultCatchErrMsg(e)}}
function createYesNoSelect(a){return createLocalDataSelect(a,{data:[{value:"",text:"\u8bf7\u9009\u62e9"},{value:"0",text:"\u662f"},{value:"1",text:"\u5426"}]})}
function createSysCode(a,b){try{var c="";"string"==typeof a?c=a:"object"==typeof a&&(c=a.id);if(""!=dealNull(c)){var d={codeType:"",codeValue:"",isShowAll:!1,isShowDefaultOption:!0};"object"==typeof a&&(d=$.extend(d,a));"object"==typeof b&&(d=$.extend(d,b));if(""!=dealNull(d.codeType)){var e="commAction!findSysCodeByCodeType.action",e=e+("?codeType="+d.codeType),e=e+("&codeValues="+dealNull(d.codeValue));"boolean"==typeof d.isShowAll&&(e+="&isShowAll="+d.isShowAll);"boolean"==typeof d.isShowDefaultOption&&
(e+="&isShowDefaultOption="+d.isShowDefaultOption);d.url=e;e={url:"commAction!findSysCodeByCodeType.action",width:174,valueField:"VALUE",editable:!1,value:"",panelMaxHeight:200,panelMinWidth:174,textField:"TEXT",panelHeight:"auto",loadFilter:function(a){"0"!=a.status&&($.messager.alert("\u7cfb\u7edf\u6d88\u606f",a.msg,"warning"),$("#"+c).combobox("disable"));return a.rows},onLoadSuccess:function(a){a=$("#"+c).combobox("getValue");"erp2_erp2"==a&&(a="");if(""==a){var b=$("#"+c).combobox("getData");
b&&0<b.length&&(a=b[0].VALUE)}$("#"+c).combobox("setValue",a)}};e=$.extend(e,d);return $("#"+c).combobox(e)}}}catch(g){defaultCatchErrMsg(g)}}
function createCustomSelect(a,b){try{var c="";"string"==typeof a?c=a:"object"==typeof a&&(c=a.id);if(""!=dealNull(c)){var d={value:"",text:"",table:"",where:"",orderby:"",from:"",to:"",isShowDefaultOption:!0,defaultValue:""},e={value:"",text:"",table:"",where:"",orderby:"",from:"",to:"",isShowDefaultOption:!0,defaultValue:""};"object"==typeof a&&(d=$.extend(d,a));"object"==typeof b&&(d=$.extend(d,b));if(""!=dealNull(d.value)&&""!=dealNull(d.text)&&""!=dealNull(d.table)){"boolean"!=typeof d.isShowDefaultOption&&
(d.isShowDefaultOption=!0);"boolean"!=typeof d.isOnlyDefault&&(d.isOnlyDefault=!1);e.value=d.value;e.text=d.text;e.table=d.table;e.where=d.where;e.orderby=d.orderby;e.from=d.from;e.to=d.to;e.isOnlyDefault=d.isOnlyDefault;e.isShowDefaultOption=d.isShowDefaultOption;var g={url:"commAction!findAllCustomCodeType.action",width:174,valueField:"VALUE",editable:!1,value:"",panelMaxHeight:200,panelMinWidth:174,method:"post",textField:"TEXT",panelHeight:"auto",loadFilter:function(a){"0"!=a.status&&($.messager.alert("\u7cfb\u7edf\u6d88\u606f",
a.msg,"warning"),$("#"+c).combobox("disable"));return a.rows},onLoadSuccess:function(a){a=$("#"+c).combobox("getValue");"erp2_erp2"==a&&(a="");if(""==a){var b=$("#"+c).combobox("getData");b&&0<b.length&&(a=b[0].VALUE)}$("#"+c).combobox("setValue",a)}},g=$.extend(g,d,{value:d.defaultValue,queryParams:e});return $("#"+c).combobox(g)}}}catch(f){defaultCatchErrMsg(f)}}
function createRegionSelect(a,b,c,d,e,g){try{var f="",h="",k="";"string"==typeof a?f=a:"object"==typeof a&&(f=a.id);if(""!=dealNull(f)&&"string"==typeof f){"string"==typeof b?h=b:"object"==typeof b&&(h=b.id);"string"==typeof c?k=c:"object"==typeof c&&(k=c.id);var m={url:"commAction!getAllRegion.action",editable:!1,cache:!0,width:174,panelMaxHeight:200,panelMinWidth:174,panelHeight:"auto",valueField:"region_Id",textField:"region_Name",onSelect:function(a){"string"==typeof h&&""!=dealNull(h)&&($("#"+
h).combobox("clear"),$("#"+h).combobox("reload","commAction!getAllTown.action?region_Id="+a.region_Id))},onLoadSuccess:function(){var a=$("#"+f).combobox("getData");0<a.length&&($("#"+f).combobox("setValue",a[0].region_Id),"string"==typeof h&&""!=dealNull(h)&&($("#"+h).combobox("clear"),$("#"+h).combobox("reload","commAction!getAllTown.action?region_Id="+a[0].region_Id)))}};"object"==typeof a&&(m=$.extend(m,a));"object"==typeof d&&(m=$.extend(m,d));$("#"+f).combobox(m);"string"==typeof h&&""!=dealNull(h)&&
(a={editable:!1,cache:!1,width:174,panelMaxHeight:200,panelMinWidth:174,panelHeight:"auto",valueField:"town_Id",textField:"town_Name",onSelect:function(a){"string"==typeof k&&""!=dealNull(k)&&($("#"+k).combobox("clear"),$("#"+k).combobox("reload","commAction!getAllComm.action?town_Id="+a.town_Id))},onLoadSuccess:function(){var a=$("#"+h).combobox("getData");0<a.length&&($("#"+h).combobox("setValue",a[0].town_Id),"string"==typeof k&&""!=dealNull(k)&&($("#"+k).combobox("clear"),$("#"+k).combobox("reload",
"commAction!getAllComm.action?town_Id="+a[0].town_Id)))}},"object"==typeof b&&(a=$.extend(a,b)),"object"==typeof e&&(a=$.extend(a,e)),$("#"+h).combobox(a),"string"==typeof k&&""!=dealNull(k)&&(b={editable:!1,cache:!1,width:174,panelMaxHeight:200,panelMinWidth:174,panelHeight:"auto",valueField:"comm_Id",textField:"comm_Name"},"object"==typeof c&&(b=$.extend(b,c)),"object"==typeof g&&(b=$.extend(b,g)),$("#"+k).combobox(b)))}}catch(l){defaultCatchErrMsg(l)}}
(function(a){a.createCustomSelect=function(b,c){try{var d="";"string"==typeof b?d=b:"object"==typeof b&&(d=b.id);if(""!=dealNull(d)){var e={value:"",text:"",table:"",where:"",orderby:"",from:"",to:"",isShowDefaultOption:!0,defaultValue:""},g={value:"",text:"",table:"",where:"",orderby:"",from:"",to:"",isShowDefaultOption:!0,defaultValue:""};"object"==typeof b&&(e=a.extend(e,b));"object"==typeof c&&(e=a.extend(e,c));if(""!=dealNull(e.value)&&""!=dealNull(e.text)&&""!=dealNull(e.table)){"boolean"!=
typeof e.isShowDefaultOption&&(e.isShowDefaultOption=!0);"boolean"!=typeof e.isOnlyDefault&&(e.isOnlyDefault=!1);g.value=e.value;g.text=e.text;g.table=e.table;g.where=e.where;g.orderby=e.orderby;g.from=e.from;g.to=e.to;g.isOnlyDefault=e.isOnlyDefault;g.isShowDefaultOption=e.isShowDefaultOption;var f={url:"commAction!findAllCustomCodeType.action",width:174,valueField:"VALUE",editable:!1,value:"",panelMaxHeight:200,panelMinWidth:174,method:"post",textField:"TEXT",panelHeight:"auto",loadFilter:function(b){"0"!=
b.status&&(a.messager.alert("\u7cfb\u7edf\u6d88\u606f",b.msg,"warning"),a("#"+d).combobox("disable"));return b.rows},onLoadSuccess:function(b){b=a("#"+d).combobox("getValue");"erp2_erp2"==b&&(b="");var c=a("#"+d).combobox("getData");""==dealNull(b)&&c&&0<c.length&&(b=c[0].VALUE);a("#"+d).combobox("setValue",b)}},f=a.extend(f,e,{value:e.defaultValue,queryParams:g});return a("#"+d).combobox(f)}}}catch(h){defaultCatchErrMsg(h)}}})(jQuery);
function createDataGrid(a,b){try{var c="";"string"==typeof a?c=a:"object"==typeof a&&(c=a.id);if(""!=dealNull(c)){var d={url:"",fit:!0,pagination:!0,rownumbers:!0,border:!1,striped:!0,singleSelect:!0,autoRowHeight:!0,showFooter:!0,toolbar:"#tb",onBeforeLoad:function(a){if("undefined"==typeof a.queryType||0!=a.queryType)return $(this).datagrid("getPager").pagination({total:0}),!1},onLoadSuccess:function(a){0!=dealNull(a.status)&&$.messager.alert("\u7cfb\u7edf\u6d88\u606f",a.errMsg,"warning")}};"object"==
typeof a&&(d=$.extend(d,a));"object"==typeof b&&(d=$.extend(d,b));return $("#"+c).datagrid(d)}}catch(e){defaultCatchErrMsg(e)}}
function zhuguan(a,b){var c;try{c=$("#"+a).combobox({width:174,mode:"remote",valueField:"operId",editable:!1,textField:"name",panelHeight:300,onSelect:function(c){"function"==typeof b?b():$("#"+a).val(c.codeValue)},loader:function(a,b,c){$.ajax({url:"recharge/rechargeAction!getBranchSupervisor.action",dataType:"json",success:function(a){b(a.rows)},error:function(){c.apply(this,arguments)}})},onLoadSuccess:function(){var a=$(this).combobox("getData");0<a.length&&$(this).combobox("setValue",a[0].operId)}});
var d=document.getElementById(a).onclick;d?document.getElementById(a).onclick=function(){d();$("#"+a).combobox("hidePanel");$("#"+a).combobox("showPanel")}:document.getElementById(a).onclick=function(){$("#"+a).combobox("hidePanel");$("#"+a).combobox("showPanel")};return c}catch(e){defaultCatchErrMsg(e)}}
function createCardType(a,b,c){if("UNDEFINED"==b||null==b)b="";try{$("#"+a).combobox({width:174,url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CARD_TYPE&codeValue="+b,valueField:"codeValue",editable:!1,textField:"codeName",panelHeight:"auto",onSelect:function(b){"function"==typeof c?c():$("#"+a).val(b.codeValue)}})}catch(d){defaultCatchErrMsg(d)}}function deteteGridAllRows(a){var b=$("#"+a),c=b.datagrid("getRows");c&&0<c.length&&(b.datagrid("deleteRow",0),deteteGridAllRows(a))}
function addValidRbm(a){var b=a.value;/^\d*(\.?\d{0,2})?$/g.test(b)||(isNaN(b)&&-1>=b.indexOf("..")?a.value=b.replace(/([\D*)|([^\.])/g,""):a.value=b.substring(0,b.length-1))}function addRbmValidById(a){a=document.getElementById(a);if("undefined"!=typeof a){var b=a.onkeydown;a.onkeydown=b?function(){b();addValidRbm(this)}:function(){addValidRbm(this)};var c=a.onkeyup;a.onkeyup=c?function(){c();addValidRbm(this)}:function(){addValidRbm(this)}}}
function addNumberValidById(a){var b=document.getElementById(a);if("undefined"!=typeof b){var c=b.onkeydown;b.onkeydown=c?function(){c();/^\d*$/g.test(this.value)||(b.value=this.value.replace(/\D/g,""))}:function(){/^\d*$/g.test(this.value)||(b.value=this.value.replace(/\D/g,""))};var d=b.onkeyup;b.onkeyup=d?function(){d();/^\d*$/g.test(this.value)||(b.value=this.value.replace(/\D/g,""))}:function(){/^\d*$/g.test(this.value)||(b.value=this.value.replace(/\D/g,""))}}}
(function(a){a.addNumber=function(a){var c=document.getElementById(a);if("undefined"!=typeof c){var d=c.onkeydown,e=c.onkeyup;c.onkeydown=function(){"function"==typeof d&&d();""==dealNull(c.value)||/^\d*$/g.test(c.value)||(c.value=c.value.replace(/\D/g,""))};c.onkeyup=function(){"function"==typeof e&&e();""==dealNull(c.value)||/^\d*$/g.test(c.value)||(c.value=c.value.replace(/\D/g,""))}}}})(jQuery);
(function(a){a.addIdCardReg=function(a){if("string"==typeof a){var c=document.getElementById(a);if("undefined"!=typeof c){var d=c.onkeydown,e=c.onkeyup;c.onkeydown=function(){"function"==typeof d&&d();""==dealNull(c.value)||/^\d{0,17}([0-9]?|[Xx]?)$/g.test(c.value)||(c.value=c.value.substring(0,c.value.length-1))};c.onkeyup=function(){"function"==typeof e&&e();""==dealNull(c.value)||/^\d{0,17}([0-9]?|[Xx]?)$/g.test(c.value)||(c.value=c.value.substring(0,c.value.length-1))};return c}}}})(jQuery);
(function(a){a.addRbmReg=function(a){if("string"==typeof a){var c=document.getElementById(a);if("undefined"!=typeof c){var d=c.onkeydown,e=c.onkeyup;c.onkeydown=function(){"function"==typeof d&&d();""!=dealNull(c.value)&&(/^\d+(\.?\d{0,2})?$/g.test(c.value)?/^0{2,}$/g.test(c.value)&&(c.value=0):c.value=c.value.substring(0,c.value.length-1))};c.onkeyup=function(){"function"==typeof e&&e();""!=dealNull(c.value)&&(/^\d+(\.?\d{0,2})?$/g.test(c.value)?/^0{2,}$/g.test(c.value)&&(c.value=0):c.value=c.value.substring(0,
c.value.length-1))}}}}})(jQuery);
(function(a){a.autoComplete=function(b,c,d){try{var e="",g="";"string"==typeof b?e=b:"object"==typeof b&&(e=b.id);if(""!=dealNull(e)){g=c;c={my:"left top",at:"left bottom"};"object"==typeof b&&""!=dealNull(b.of)&&(c=a.extend(c,{of:"#"+b.of}));"object"==typeof d&&""!=dealNull(d.of)&&(c=a.extend(c,{of:"#"+d.of}));var f={value:"",text:"",table:"",keyColumn:"",where:"",orderby:"",from:"",to:"",optimize:!1,reverse:!1};"object"==typeof b&&(f=a.extend(f,b));"object"==typeof d&&(f=a.extend(f,d));if(""!=dealNull(f.text)&&
""!=dealNull(f.table)&&""!=dealNull(f.keyColumn)){var h={position:{my:"left top",at:"left bottom",of:""==dealNull(f.of)?"#"+e:"#"+f.of},minLength:4,delay:300,source:function(b,c){f.keyValue=b.term;a.post("commAction!findAllCustomAuto.action",f,function(b){c(a.map(b.rows,function(a){return{label:a.TEXT_,value:a.VALUE_}}))},"json")},select:function(b,c){""!=dealNull(g)&&("boolean"==typeof f.reverse&&f.reverse?a("#"+g).val(c.item.label):a("#"+g).val(c.item.value));""!=dealNull(f.of)?"boolean"==typeof f.reverse&&
f.reverse?a("#"+f.of).val(c.item.value):a("#"+f.of).val(c.item.label):""!=dealNull(e)&&("boolean"==typeof f.reverse&&f.reverse?a("#"+e).val(c.item.value):a("#"+e).val(c.item.label));return!1},focus:function(b,c){""!=dealNull(g)&&("boolean"==typeof f.reverse&&f.reverse?a("#"+g).val(c.item.label):a("#"+g).val(c.item.value));""!=dealNull(f.of)?"boolean"==typeof f.reverse&&f.reverse?a("#"+f.of).val(c.item.value):a("#"+f.of).val(c.item.label):""!=dealNull(e)&&("boolean"==typeof f.reverse&&f.reverse?a("#"+
e).val(c.item.value):a("#"+e).val(c.item.label));return!1}};if(""!=dealNull(g)){var k=document.getElementById(e);if("undefined"!=typeof k){var m=k.onkeydown;k.onkeydown=function(){m&&m();""==dealNull(k.value)&&a("#"+g).val("")};var l=k.onkeyup;k.onkeyup=function(){l&&l();""==dealNull(k.value)&&a("#"+g).val("")}}}"object"==typeof b&&(h=a.extend(h,b));"object"==typeof d&&(h=a.extend(h,d));a("#"+e).autocomplete(h)}}}catch(p){defaultCatchErrMsg(p)}}})(jQuery);
(function(a){a.foramtMoney=function(a){num=a.replace(/\$|\,/g,"");isNaN(num)&&(num="0");sign=num==(num=Math.abs(num));num=Math.floor(100*num+.50000000001);cents=num%100;num=Math.floor(num/100).toString();10>cents&&(cents="0"+cents);for(a=0;a<Math.floor((num.length-(1+a))/3);a++)num=num.substring(0,num.length-(4*a+3))+","+num.substring(num.length-(4*a+3));return(sign?"":"-")+num+"."+cents}})(jQuery);
function createDealCode(a,b){try{var c="";"string"==typeof a?c=a:"object"==typeof a&&(c=a.id);if(""!=dealNull(c)){var d={url:"commAction!findAllDealCodes.action",editable:!0,cache:!1,width:174,panelHeight:"auto",panelWidth:250,groupField:"GCODE",panelMinWidth:174,panelMaxHeight:200,valueField:"CODE_VALUE",textField:"CODE_NAME",groupFormatter:function(a){return'<span style="color:red;font-weight:600;font-style:italic;">'+a+"</span>"}};"object"==typeof a&&(d=$.extend(d,a));"object"==typeof b&&(d=$.extend(d,
b));$("#"+c).combobox(d)}}catch(e){defaultCatchErrMsg(e)}}
(function(a){a.createDealCode=function(b,c){try{var d="";"string"==typeof b?d=b:"object"==typeof b&&(d=b.id);if(""!=dealNull(d)){var e={url:"commAction!findAllDealCodes.action",editable:!0,cache:!1,width:174,panelHeight:"auto",panelWidth:250,groupField:"GCODE",panelMinWidth:174,panelMaxHeight:200,valueField:"CODE_VALUE",textField:"CODE_NAME",groupFormatter:function(a){return'<span style="color:red;font-weight:600;font-style:italic;">'+a+"</span>"}};"object"==typeof b&&(e=a.extend(e,b));"object"==
typeof c&&(e=a.extend(e,c));a("#"+d).combobox(e)}}catch(g){defaultCatchErrMsg(g)}}})(jQuery);(function(a){a.initLocalDataSelect=function(b,c){try{var d="";"string"==typeof b?d=b:"object"==typeof b&&(d=b.id);if(""!=dealNull(d)){var e={width:174,valueField:"VALUE",editable:!1,value:"",panelMaxHeight:200,panelMinWidth:174,textField:"TEXT",panelHeight:"auto"};"object"==typeof b&&(e=a.extend(e,b,{url:""}));"object"==typeof c&&(e=a.extend(e,c,{url:""}));return a("#"+d).combobox(e)}}catch(g){defaultCatchErrMsg(g)}}})(jQuery);
function tensileStringByByte(a,b,c,d){""==a&&(a=" ");""==dealNull(b)&&(b=a.byteLen());"boolean"==typeof c&&(c=!0);"undefined"==typeof d&&(d=" ");var e=a.byteLen();if(e>=b)return a.substring(0,b);for(;e<b;)a=c?d+a:a+d,e=a.byteLen();return a}
function selectByType(a,b,c){try{$("#"+a).combobox({width:174,url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType="+b,valueField:"codeValue",editable:!1,textField:"codeName",panelHeight:"auto",onSelect:function(b){"function"==typeof c?c():$("#"+a).val(b.codeValue)}})}catch(d){defaultCatchErrMsg(d)}}
function getSearchInputData(a,b,c,d,e,g){try{$("#"+a).combobox({url:"/commAction!getSearchInputData.action?tablename="+b+"&colname="+c+"&colvalue="+d+"&value="+e+"&flag=true",editable:!1,textField:d,valueField:c,width:174,value:e,onLoadSuccess:function(){var b=$("#"+a).combobox("getData");0<b.length&&$("#"+a).combobox("select",dealNull(b[0].colname));"function"==typeof g&&g()}})}catch(f){defaultCatchErrMsg(f)}}
function getformdata(a){try{var b={isNotBlankNum:0,isBlankNum:0},c=$("#"+a).serialize(),d;if(0==dealNull(c).length)return b;d=c.split("&");for(a=0;a<d.length;a++){var e=d[a].split("=");0==dealNull(e[1]).length?(b[e[0]]="",b.isBlankNum=Number(b.isBlankNum)+Number("1")):(b[e[0]]=e[1],b.isNotBlankNum=Number(b.isNotBlankNum)+Number("1"))}return b}catch(g){return defaultCatchErrMsg(g),{}}}
function jAlert(a,b,c){var d="",d=""==dealNull(b)||"string"!=typeof b?"error":b;$.messager.alert("\u7cfb\u7edf\u6d88\u606f",a,d,function(){"function"==typeof c&&c()})}function jConfirm(a,b,c){$.messager.confirm("\u7cfb\u7edf\u6d88\u606f",a,function(a){a?"function"==typeof b&&b():"function"==typeof c&&c()})}
function defaultCatchErrMsg(a){errorsMsg="";for(i in a)errorsMsg+=i+":"+eval("e."+i)+"\n";""==dealNull(errorsMsg)&&(errorsMsg=a.toString());$.messager.alert("\u7cfb\u7edf\u6d88\u606f",errorsMsg,"error");return errorsMsg}
Date.prototype.format=function(a){var b={"M+":this.getMonth()+1,"d+":this.getDate(),"h+":this.getHours(),"m+":this.getMinutes(),"s+":this.getSeconds(),"q+":Math.floor((this.getMonth()+3)/3),S:this.getMilliseconds()};/(y+)/.test(a)&&(a=a.replace(RegExp.$1,(this.getFullYear()+"").substr(4-RegExp.$1.length)));for(var c in b)(new RegExp("("+c+")")).test(a)&&(a=a.replace(RegExp.$1,1==RegExp.$1.length?b[c]:("00"+b[c]).substr((""+b[c]).length)));return a};
Date.prototype.addDays=function(a){this.setDate(this.getDate()+a)};Date.prototype.addWeeks=function(a){this.addDays(7*a)};Date.prototype.addMonths=function(a){var b=this.getDate();this.setMonth(this.getMonth()+a);this.getDate()<b&&this.setDate(0)};Date.prototype.addYears=function(a){var b=this.getMonth();this.setFullYear(this.getFullYear()+a);b<this.getMonth()&&this.setDate(0)};
// 金融社保卡市民卡网点对应银行领卡网点
var brchTolkbrch = [
	// 市本级
	{
		10010001 : {
			100003000000008 : 20010101, // 禾商
			100003000000001 : 20010231, // 邮储
			100003000000004 : 20010311  // 农行
		}
	},
	// 海宁市
	{
		10020001 : {
			100003000000010 : 20020101, // 海宁农商
			100003000000001 : 20020202, // 邮储
			100003000000004 : 20020301  // 农行
		}
	},
	// 海盐县
	{
		10060001 : {
			100003000000009 : 20060109, // 海盐农信
			100003000000001 : 20060201, // 邮储
			100003000000004 : 20060301  // 农行
		}
	},
	// 平湖市
	{
		10040001 : {
			100003000000012 : 20040101, // 平湖农商
			100003000000001 : 20040202, // 邮储
			100003000000004 : 20040301  // 农行
		}
	},
	// 桐乡市
	{
		10030001 : {
			100003000000013 : 20030101, // 桐乡农商
			100003000000001 : 20030202, // 邮储
			100003000000004 : 20030301  // 农行
		}
	},
	// 嘉善县
	{
		10050001 : {
			100003000000011 : 20050122, // 桐乡农商
			100003000000001 : 20050201, // 邮储
			100003000000004 : 20050301  // 农行
		}
	}
];

var curBrchId = "";
var curBankId = "";

function createRecvBranch(id,foptions){
	try{
		var defalutId = "";
		if(typeof(id) == "string"){
			defalutId = id;
		}else if(typeof(id) == "object"){
			defalutId = id["id"];
		}else{
			return;
		}
		if(dealNull(defalutId) == "" || typeof(defalutId) != "string"){
			return;
		}
		var options_ = {
			url:"commAction!findAllRecvBranch.action",
			editable:false,
			method:"post",
			panelHeight:'auto',
			panelMaxHeight:200,
			panelMinWidth:174,
			panelWidth:260,
			queryParams:{isJudgePermission:true},
			width:174,
			checkbox:false,
			cascadeCheck:false,
			cache:true,
			lines:true,
			animate:true,
			loadFilter:function(data){
				if(data.status != "0"){
					$.messager.alert("系统消息",data.msg,"warning");
					$("#" + defalutId).combotree("disable");
				}
				curBrchId = data.brchId;
				curBankId = data.bankId;
				return data.rows;
			},
			onLoadSuccess:function(node,data){
				if(data && data.length > 0){
					var defaultValue = $("#" + defalutId).combotree("getValue");
					if(defaultValue == "erp2_erp2"){
						defaultValue = "";
					}
					if(dealNull(defaultValue) == ""){
						defaultValue = data[0].id;
					}
					if(defaultValue != "" && defaultValue != "erp2_erp2" && data.length == 1){
						$("#" + defalutId).combotree("readonly",true);
					}else{
						$("#" + defalutId).combobox('readonly',false);
					}
					var t_options = $("#" + defalutId).combotree("options");
					if(typeof(t_options["isReadOnly"]) == "boolean" && t_options["isReadOnly"] == true){
						$("#" + defalutId).combotree("readonly",true);
					}
					$("#" + defalutId).combotree("setValue",defaultValue);
				}
				if(curBankId){
					for(var i in brchTolkbrch){
						if(brchTolkbrch[i][curBrchId]){
							if(brchTolkbrch[i][curBrchId][curBankId]){
								$("#" + defalutId).combotree("setValue",brchTolkbrch[i][curBrchId][curBankId]);
							}
							break;
						}
					}
				}
			}
		};
		if(typeof(id) == "object"){
			$.extend(options_,id);
		}
		if(typeof(foptions) == "object"){
			$.extend(options_,foptions);
		}
		return $("#" + defalutId).combotree(options_);
	}catch(e){
		errorsMsg = "";
		for(i in e){
			errorsMsg += i + ":" + eval("e." + i) + "\n";
		}
		$.messager.alert('系统消息',errorsMsg,'error');
	}
};