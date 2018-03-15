<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
	$(function() {
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
	});
	function saveUsersPwd(){
		if(dealNull($("#userId").val()).length == 0){
			$.messager.alert("系统消息","柜员编号不能为空！","error",function(){
				$("#userId").focus();
			});
			return false;
		}
		if(dealNull($("#oldPwd").val()).length == 0){
			$.messager.alert("系统消息","请输入原密码！","error",function(){
				$("#oldPwd").focus();
			});
			return false;
		}
		if(dealNull($("#pwd").val()).length == 0){
			$.messager.alert("系统消息","请输入新密码！","error",function(){
				$("#pwd").focus();
			});
			return false;
		}
		/* if (!$("#pwd").val().match(/(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^.{8,16}$/)){ 
			$.messager.alert("系统消息","新密码必须是数字或字母或字符的组合密码，且密码长度不能小于8位，最大16位","error",function(){
				$("#pwd").focus();
			});
			return false; 
		}  */
		if(dealNull($("#oldPwd")).val() == $("#pwd").val()){
			jAlert("原密码和新密码不能相同！","error",function(){
				$("#pwd").focus();
			});
			return false;
		}
		if($("#confirmPwd").val() != $("#pwd").val()){
			$.messager.alert("系统消息","确认密码和新密码不相同，请重新进行输入！","error",function(){
				$("#confirmPwd").focus();
			});
			return false;
		}
		if(dealNull($("#name").val()).length == 0){
			$.messager.alert("系统消息","柜员名称不能为空！","error",function(){
				$("#name").focus();
			});
			return false;
		}
		if(dealNull($("#brchId").val()).length == 0){
			$.messager.alert("系统消息","柜员所属网点不能为空！","error",function(){
			});
			return false;
		}
		$.messager.progress({text:'数据处理中，请稍后....'});
		$.post("user/userAction!saveUserPwd.action",$("#formPwd").serialize(),function(data,status){
			$.messager.progress('close');
			if(data.status == "0"){
				alertWin();
			}else{
				if(dealNull(data.msg).indexOf("解锁") > -1){
					$("#tipwinerr").window("open");
				}else{
					$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						if(data.status == "0"){
							$.modalDialog.handler.dialog('close');
						}
					});
				}
			}
		},"json");
	}
	function cancelPwd2(){
		$.modalDialog.handler.dialog("destroy");
	    $.modalDialog.handler = undefined;
	}
	function alertWin(){
		$("#tipwin").window("open");
	}
	function onCloseWin(){
		$("#tipwin").window("close");
	}
	function reLoginLogin(){
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
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false" title="" style="overflow:hidden;padding:1px;background-color:rgb(245,245,245);">
		<form id="formPwd" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>柜员密码修改</legend>
				<input name="users.myid" id="myid1"  type="hidden" value="${users.myid}" />
				<input name="users.userId" id="myid2"  type="hidden" value="${users.userId}" />
				<input name="users.brchId" id="myid3"  type="hidden" value="${users.brchId}" />
				<table class="tablegrid">
					<tr>
					    <th class="tableleft">所属网点：</th>
						<td class="tableright"><input id="brchId" name="state" value="${state}" type="text" class="textinput easyui-validatebox" disabled="disabled"/></td>
					    <th class="tableleft">柜员编号：</th>
						<td class="tableright"><input value="${users.userId}" name="userId" id="userId" class="textinput easyui-validatebox" type="text" disabled="disabled" /></td>
					</tr>
					<tr>
					    <th class="tableleft">柜员名称：</th>
						<td class="tableright"><input value="${users.name}" name="users.name" id="name" type="text" class="textinput easyui-validatebox" disabled="disabled" required="required"/></td>
					    <th class="tableleft easyui-tooltip" data-options="content:'密码的有效期限，超过密码的有效期限则无法进行系统登录<br>请定期修改密码以确保登录密码有效！'">密码有效期：</th>
						<td class="tableright easyui-tooltip" data-options="content:'密码的有效期限，超过密码的有效期限则无法进行系统登录<br>请定期修改密码以确保登录密码有效！'"><input value="${users.fullName}" name="fullName" id="fullName" type="text" class="textinput easyui-validatebox" disabled="disabled" required="required"/></td>
					</tr>
					<tr>
					    <th class="tableleft">原密码：</th>
						<td class="tableright" colspan="3"><input name="oldPwd" id="oldPwd" type="password" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入原登录密码',invalidMessage:'请输入原登录密码'" maxlength="16"/></td>
					</tr>
					<tr>
					    <th class="tableleft">新密码：</th>
						<td class="tableright"><input name="pwd" id="pwd" type="password" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入新密码',invalidMessage:'请输入新密码'" maxlength="16"/></td>
					    <th class="tableleft">确认密码：</th>
						<td class="tableright"><input name="confirmPwd" id="confirmPwd" type="password" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入确认密码',invalidMessage:'请输入确认密码'" maxlength="16"/></td>
					</tr>
					<tr>
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr>
						<td colspan="4" style="text-align:center;height:40px;">
							<a class="easyui-linkbutton" data-options="" href="javascript:void(0)" onclick="javascript:saveUsersPwd()" style="width:80px">确定</a>
							<a class="easyui-linkbutton" data-options="" href="javascript:void(0)" onclick="javascript:cancelPwd2()" style="width:80px">取消</a>
						</td>
					</tr>
				</table>
			<div style="font-size:10px;font-family:'微软雅黑';color:purple;margin-top:3px;">请定期修改登录密码，以确保密码更安全；如密码过期，请联系系统管理员进行密码重置！</div>
			</fieldset>
		</form>
		<div id="tipwin" title="系统消息" class="easyui-window" data-options="modal:true,closed:true,maximizable:false,minimizable:false,collapsible:false,closable:false" style="width:288px;height:122px;padding:10px;">
			<table style="width:100%;height:100%">
				<tr>
					<td class="messager-info" style="width:30px;height:30px;overflow:hidden;">&nbsp;</td>
					<td>密码修改成功，请重新进行登录！</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:center;"><a class="easyui-linkbutton" data-options="" href="javascript:void(0)" onclick="javascript:reLoginLogin()" style="width:80px">确定</a></td>
				</tr>
			</table>
		</div>
		<div id="tipwinerr" title="系统消息" class="easyui-window" data-options="modal:true,closed:true,maximizable:false,minimizable:false,collapsible:false,closable:false" style="width:288px;height:122px;padding:10px;">
			<table style="width:100%;height:100%">
				<tr>
					<td class="messager-error" style="width:30px;height:30px;overflow:hidden;">&nbsp;</td>
					<td>当前柜员输入的密码错误次数超限，请联系系统管理员进行解锁！</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:center;"><a class="easyui-linkbutton" data-options="" href="javascript:void(0)" onclick="javascript:reLoginLogin()" style="width:80px">确定</a></td>
				</tr>
			</table>
		</div>
	</div>
</div>