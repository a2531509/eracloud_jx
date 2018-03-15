<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>柜员轧账</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/initpage.jsp"></jsp:include> 
	<script type="text/javascript">
		function tempDayBal(){
			//查灰记录
			$.messager.progress({text : '数据处理中，请稍后....'});
			$.post('recharge/rechargeAction!dealAshRecord.action', {operId:"${user.userId}", rows:1, queryType:0}, function(data){
				$.messager.progress('close');
				var hasHjl = false;
				if(data.rows.length > 0){
					hasHjl = true;
				}
				$.messager.confirm('确认对话框', (hasHjl?"<span style='color:red'>有灰记录未处理</span>，":"") + '您确定要进行轧账吗？轧账后将无法登录系统', function(r){
					if (r){
						$.messager.progress({text : '数据处理中，请稍后....'});
						$.post('cuteDayManage/cuteDayAction!userDayBal.action',
								{
									dealType:'1'
								},function(result){
									$.messager.progress('close');
									if(result.status =='1'){
										$.messager.alert('系统消息',result.msg,'error');
									}else{
										parent.showReport("<%=com.erp.util.Constants.APP_REPORT_TITLE%>",result.actionNo,function(){
											// logout
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
										});
									}
								},'json');
					}
				});
			}, "json");
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>每天的业务</strong></span>进行汇总！</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true,fit:true" style="border-top:none;border-left:none;border-bottom:none;height:auto;overflow:hidden;background-color:rgb(245,245,245);">
			<div id="tb" title="柜员扎帐" style="padding:20px 80px 20px;" class="easyui-panel datagrid-toolbar" data-options="fit:true">
				<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:10%">柜员编号：</td>
						<td class="tableright" style="width:20%"><input id="userId" type="text" class="textinput" name="user.userId" value="${user.userId}"  style="cursor:pointer;" readonly="readonly" /></td>
						<td class="tableleft" style="width:10%">柜员名称：</td >
						<td class="tableright" style="width:20%"><input id="userName" type="text" class="textinput" name="user.name" value="${user.name}" style="cursor:pointer;" readonly="readonly" /></td>
						<td class="tableleft" style="width:10%">轧账日期：</td>
						<td class="tableright" style="width:20%">
							<input id="clrDate" type="text" name="clrDate" class="textinput" value="${clrDate}" readonly="readonly"/>
						<td class="tableright">
							<shiro:hasPermission name="userCuteDayEnd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ok"  plain="false" onclick="tempDayBal();">轧账</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  </div>
  </body>
</html>