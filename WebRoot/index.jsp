<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<base href="<%=basePath%>">
	<title>欢迎登录<%=com.erp.util.Constants.APP_REPORT_TITLE %></title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="layout/script.jsp"></jsp:include>

	<script type="text/javascript">

        $(function(){
            downloadworkkey();
            initTopMenu();
            initMenu();//第一次登陆默认显示第一个
            if (jqueryUtil.isLessThanIe8()) {
                $.messager.show({
                    title : '警告',
                    msg : '您使用的浏览器版本太低！<br/>建议您使用谷歌浏览器来获得更快的页面响应效果！',
                    timeout : 1000 * 30
                });
            }
        });
        //下载密码键盘工作密钥
        function downloadworkkey(){
            $.post("systemAction!getMainkeyandWorkKey.action",function(data){
                if(data['status'] == '0'){
                    if(!cardDownloadUserKey(data['workkey'])){
                        jAlert("下载工作密钥失败，请重新进行登录！");
                    }
                }else if(data['status'] == '1'){
                }
            },"json");
        }

        function initMenu(){
            var $ma=$("#menuAccordion");
            $ma.accordion({animate:true,fit:true,border:false});
            $.post("systemAction!findAllFunctionList.action", {userName:"1"}, function(rsp){
                var i = 0
                $.each(rsp,function(i,e){
                    var menulist ="<div class=\"well well-small datagrid-toolbar\">";
                    if(e.child && e.child.length>0){
                        $.each(e.child,function(ci,ce){
                            var effort=ce.name+"||"+ce.iconCls+"||"+ce.url;
                            menulist+="<a href=\"javascript:void(0);\" class=\"easyui-linkbutton\" data-options=\"plain:true,iconCls:'"+ce.iconCls+"'\" onclick=\"addTab('"+effort+"');\">"+ce.name+"</a><br/>";
                        });
                    }
                    menulist+="</div>";
                    if(i == 0){
                        $ma.accordion('add', {
                            title: e.name,
                            content: menulist,
                            border:false,
                            iconCls: e.iconCls,
                            selected:true
                        });
                    }else{
                        $ma.accordion('add', {
                            title: e.name,
                            content: menulist,
                            border:false,
                            iconCls: e.iconCls,
                            selected:false
                        });
                    }
                    i++;
                });
            }, "JSON").error(function() {
                $.messager.alert("提示", "获取菜单出错,请重新登陆!");
            });
        }
        function InitLeftMenuByClick(pid){
            hoverMenuItem();
            var $ma=$("#menuAccordion");
            $ma.accordion({animate:true,fit:true,border:false});
            $.post("systemAction!findFunctionByPidList.action?ppid="+pid, {userName:"1"}, function(rsp,status){
                $.each(rsp,function(i,e){
                    var menulist ="<div class=\"well well-small datagrid-toolbar\" data-options=\"selected:true\">";
                    if(e.child && e.child.length>0){
                        $.each(e.child,function(ci,ce){
                            var effort=ce.name+"||"+ce.iconCls+"||"+ce.url;
                            menulist+="<a href=\"javascript:void(0);\" class=\"easyui-linkbutton\" data-options=\"plain:true,iconCls:'"+ce.iconCls+"'\" onclick=\"addTab('"+effort+"');\">"+ce.name+"</a><br/>";
                        });
                    }
                    menulist+="</div>";
                    $ma.accordion('add', {
                        title: e.name,
                        content: menulist,
                        border:false,
                        iconCls: e.iconCls,
                        selected:false
                    });
                });
                $("#menuAccordion").accordion("select",0);
            }, "JSON").error(function(x,ystate,z){
                $.messager.progress('close');
                if(ystate == "parsererror"){
                    window.history.go(0);
                }
            });
        }
        function Clearnav() {
            var pp = $('#menuAccordion').accordion('panels');
            $.each(pp, function(i, n) {
                if (n) {
                    var t = n.panel('options').title;
                    $('#menuAccordion').accordion('remove', t);
                }
            });

            pp = $('#menuAccordion').accordion('getSelected');
            if (pp) {
                var title = pp.panel('options').title;
                $('#menuAccordion').accordion('remove', title);
            }

        }
        function initTopMenu(){
            $.post("systemAction!findAllTopFunctionList.action", {userName:"1"}, function(rsp) {
                var toplist ="";
                $.each(rsp,function(i,e){
                    if(i==0){
                        toplist+="<li><a id='"+e.id+"' class='active' style='text-decoration:none;' ondblclick='return false;' name='"+e.myId+"' href='javascript:;' >"+e.name+" </a></li>"
                    }else{
                        toplist+="<li><a id='"+e.id+"' style='text-decoration:none;' ondblclick='return false;' name='"+e.myId+"' href='javascript:;'>"+e.name+" </a></li>"
                    }
                });
                $("#css3menu").append(toplist);

                //绑定click事件显示左边栏菜单
                $('#css3menu a').click(function() {
                    if($(this).attr("class") == 'active'){
                        return;
                    }
                    $('#css3menu a').removeClass('active');
                    $(this).addClass('active');
                    var pid = $(this).attr('id');
                    for(var i=0;i<5;i++){
                        Clearnav();
                    }
                    InitLeftMenuByClick(pid);
                });
            }, "JSON").error(function() {
                $.messager.alert("提示", "获取菜单出错,请重新登陆!");
            });
        }

        /**
         * 菜单项鼠标Hover
         */
        function hoverMenuItem() {
            $("#menuAccordion").find('a').hover(function() {
                $(this).parent().addClass("hover");
            }, function() {
                $(this).parent().removeClass("hover");
            });
        }

	</script>
	<style type="text/css">
		#menuAccordion a.l-btn span span.l-btn-text {
			height: 24px;
			line-height: 24px;
			vertical-align: middle;
			text-align:left;
			width: 135px;
			border:none;
			outline: none;
		}
		#menuAccordion span:focus{
			outline: none;
		}
		#menuAccordion .well-small {
			border-radius: 3px 3px 3px 3px;
			padding: 9px;
		}
		#menuAccordion .well {
			border: 1px solid #E3E3E3;
			border-radius: 4px 4px 4px 4px;
			box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05) inset;
			margin: 5px;
			/*min-height: 20px;*/
			padding: 9px;
		}
		#css3menu li
		{
			float: left;
			list-style-type: none;
		}
		#css3menu li a
		{
			color: #fff;
			padding:5px 10px;
		}
		#css3menu li a.active
		{
			color: yellow;
			font-weight:700;
			border-bottom: 2px solid yellow;
			box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) outset, 0 0 8px rgba(82, 168, 236, 0.6);
		}
		a.zhuxiao{
			background:url(themes/icons/logout.png) no-repeat left center;
		}
	</style>
</head>
<body class="easyui-layout">
<div id="dd" class="easyui-dialog" title="系统消息" style="width:600px;height:350px;text-align:left;padding-top: 10%;padding-left: 5%;overflow: hidden;">
	<table cellspacing="0" cellpadding="0" style="font-size:30px;" align="center">
		<tr>
			<th>当前网点：</th>
			<th ><span style='color:red'>${sessionScope.curUsers_['brchName']}</span></th>
		</tr>
		<tr>
			<th>当前柜员：</th>
			<th><span style='color:red'>${sessionScope.curUsers_['name']}</span></th>
		</tr>
		<tr>
			<th>密码有效期：</th>
			<th><span style='color:red'>${sessionScope.curUsersPassValid_}</span>（天）</th>
		</tr>
	</table>
</div>
<div data-options="region:'north',border:false" style="height:40px;padding:0px;overflow: visible;"  href="layout/north.jsp"></div>
<div data-options="region:'west',split:true,title:'导航菜单',border:true,iconCls:'icon_ico_02'" style="width:200px;">
	<div id="menuAccordion"></div>
</div>
<div data-options="region:'south',border:false,split:false" style="overflow:hidden;height:25px;padding:0px;" href="layout/south.jsp"></div>
<div data-options="region:'center',plain:true,border:true"  style=""  href="layout/center.jsp"></div>
<%--	<jsp:include page="user/loginAndReg.jsp"></jsp:include>--%>
</body>
</html>
