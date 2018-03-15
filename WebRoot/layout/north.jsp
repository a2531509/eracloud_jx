<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<script type="text/javascript" charset="utf-8">
	function logout(b) {
		$.messager.confirm("系统消息", "确认退出吗?",function(r){
			if(r){
				//commonDwr.logout();
				$.ajax({
					async : false,
					cache : false,
					type : "POST",
					url : "/systemAction!cclogout.action",
					error : function() {
						$.ajax({
							async : false,
							cache : false,
							type : "POST",
							url : "/logout",
							error : function() {
							},
							success : function(json) {
								location.replace("login.jsp");
							}
						});
					},
					success : function(json) {
						$.ajax({
							async : false,
							cache : false,
							type : "POST",
							url : "/logout",
							error : function() {
							},
							success : function(json) {
								location.replace("login.jsp");
							}
						});
					}
				});
				
			}
		});
	}
	var userInfoWindow;
	function showUserInfo() {
		$.modalDialog({
			modal:true,
			title:'密码修改',
			iconCls:'icon-role',
			width:600,
			height:280,
			collapsible:false,
			minimizable:false,
			maximizable:false,
			border:'thin',cls:'c6',
			href:'user/userAction!editPwdIndex.action?userId=${sessionScope.curUsers_["userId"]}'
		}); 
	}
	$('#logouts').hover(function(){
        $(this).css({"font-weight":"600","color":"yellow","font-size":"16px"});
       },function(){
    	$(this).css({"font-weight":"400","color":"#FFF","font-size":"12px"});
    });
	$('#updatePwd').hover(function(){
        $(this).css({"font-weight":"600","color":"yellow","font-size":"16px"});
       },function(){
    	$(this).css({"font-weight":"400","color":"#FFF","font-size":"12px"});
    });
</script>
<div id="toptitle" split="true" border="false" style="overflow: hidden; height: 40px; line-height: 40px; color: #fff; font-family: Verdana, 微软雅黑,黑体" class="datagrid-toolbar">
        <div>
        	<div style="float: left;"><img src="images/blocks.gif" width="42" height="42" align="absmiddle" /><span id="erp2_title">嘉兴市民一卡通平台</span></div>
        	<div style="padding-left:20px;">
	       		<ul id="css3menu" style="padding:0px;margin:0px;list-type:none;float:left;margin-left:40px;"></ul>
	        </div>
		    <div style="float:right;">
		    	<table>
		    		<tr>
		    			<td style="padding-right:20px;font-weight:500;">
					    	<span style="font-weight:500;">欢迎您：${sessionScope.curUsers_["name"]}，所属网点：${sessionScope.curUsers_["brchName"]}，编号：${sessionScope.curUsers_["userId"]}</span>
		    			</td>
		    			<td style="width:55px;">
							<a id="logouts" href="javascript:void(0);" onclick="logout()" style="text-decoration:none;color:#FFF;padding:0 3px 0 18px;" class="zhuxiao">注销</a>
		    			</td>
		    			<td style="width:55px;">
		    				<a id="updatePwd" href="javascript:void(0);" onclick="showUserInfo()" style="text-decoration:none;color:#FFF;padding:0 3px 0 18px;background-position:left center;background-repeat:no-repeat;" class="icon-role">密码</a>
		    			</td>
		    		</tr>
				</table>
			</div>
        </div>
		<div id="layout_north_zxMenu" style="width: 100px; display: none;">
			<div onclick="loginAndRegDialog.dialog('open');">锁定窗口</div>
			<div class="menu-sep"></div>
			<div onclick="logout();">重新登录</div>
			<div onclick="logout(true);">退出系统</div>
		</div>
</div>
