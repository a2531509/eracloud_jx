<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>Insert title here</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function(){
		    
	})
	
	function changePwd(){
		var oldPwd = $("#oldPwd").val();
		var newPwd = $("#newPwd").val();
		var confirmNewPwd = $("#confirmNewPwd").val();
		
		if(!oldPwd || !oldPwd.trim()){
			jAlert("旧密码不能为空！", "warning", function(){
				$("#oldPwd").focus();
			});
			return;
		} else if(!newPwd || !newPwd.trim()){
			jAlert("新密码不能为空！", "warning", function(){
				$("#newPwd").focus(); 
			});
			return;
		} else if(oldPwd == newPwd){
			jAlert("新密码不能不能与旧密码相同！", "warning", function(){
				$("#newPwd").focus(); 
			});
			return;
		} else if(newPwd != confirmNewPwd){
			jAlert("确认密码不一致！", "warning", function(){
				$("#confirmNewPwd").focus();
			});
			return;
		}
		
		$.messager.confirm("系统消息", "确认修改当前柜员【${userId}】登录密码?", function(r){
			if(r){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.post("user/userAction!changeUserPwd.action", {oldPwd:oldPwd, newPwd:newPwd}, function(data){
					$.messager.progress("close");
					if(!data){
						jAlert("系统没有返回数据");
						return;
					} else if(data.status != 0){
						jAlert(data.errMsg);
						return;
					} else if(data.status == 0){
						jAlert("修改密码成功", "info", function(){
							//parent.logout();
						});
					} else {
						
					}
				}, "json");
			}
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span> <span>在此可以进行修改<span
				class="label-info"><strong>当前柜员密码</strong></span>操作
			</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left: none; border-bottom: none; height: auto; overflow: hidden;">
		<div style="padding: 5% 0; height: 100%;border-left:none;border-bottom:none;" title="修改【${userId}】密码" class="easyui-panel datagrid-toolbar"  data-options="fit:true,border:false,iconCls:'icon-grid-title'">
			<table width="100%">
				<tr style="border: none;">
					<td align="center">
						旧密码:&nbsp;<input id="oldPwd" class="textinput" type="password">&nbsp;&nbsp;
						新密码:&nbsp;<input id="newPwd" class="textinput" type="password">&nbsp;&nbsp;
						确认新密码:&nbsp;<input id="confirmNewPwd" class="textinput" type="password">&nbsp;&nbsp; 
						<a style="text-align: center; margin: 0 auto; margin-right: 100px;" data-options="iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="changePwd()">修改密码</a>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>