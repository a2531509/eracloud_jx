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
    <title>柜员轧帐</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		$(function() {
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : '/cuteDayManage/cuteDayAction!findAllUsers.action',
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				fitColumns: true,
				scrollbarSize:0,
				striped:true,
				toolbar:'#tb',
				columns : [ [ {field : 'ID',title:'id',sortable:true,checkbox:'ture'},
				              {field : 'USER_ID',title : '柜员编码',width : parseInt($(this).width() * 0.1),sortable:true},
				              {field : 'USER_NAME',title : '柜员名称',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'ISEMPLOYEE',title : '是否已轧帐',width : parseInt($(this).width()*0.1),formatter:function(value,row){
			            		  if("0"==row.ISEMPLOYEE)
										return "<font color=red>是<font>";
				            		  else
				            			return "<font color=green>否<font>";  
								}}
				              ]],
				loadFilter:function(data){
					var rows = data.rows;
					for(var i = 0; i< rows.length; i++){
						if(rows[i].ISEMPLOYEE == 0){
							rows.splice(i--, 1);
							data.total--;
						}
					}
					
					return data;
				},
				onLoadSuccess:function(data){
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			});
		});
	
		function tempDayBal(){
			window.location.href = "/cuteDayManage/cuteDayAction!brchDayBal.action?dealType=1";
		}
		
		function enforceUserDayBal(){
			//判断是否选择了柜员信息
			var rows = $dg.datagrid('getChecked');
			if(rows.length>=1){
				//判断是否勾选了已轧帐的柜员
				var isDayBal = 0;
				for(var i=0;i<rows.length;i++){
					if(rows[i].ISEMPLOYEE == '0'){
						isDayBal = isDayBal+1;
					}
				}
				if(isDayBal >0 ){
					$.messager.alert('系统消息','勾选了已轧帐的柜员,请重新勾选','error');
					return;
				}
				//组装传入的参数
				var userIds = '';
				for(var i=0;i<rows.length;i++){
					userIds = userIds + rows[i].ID + '|';
				}
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post('cuteDayManage/cuteDayAction!reforceUserDayBal.action',
						{checkIds:userIds},
						function(result){
							$.messager.progress('close');
							if(result.status =='1'){
								$.messager.alert('系统消息',result.msg,'error');
								return;
							}else{
								//打开新的浏览器窗口打印报表 （未实现）
								parent.$.messager.show({
									title : result.title,
									msg : result.msg,
									timeout : 1000 * 2
								});
								window.history.go(0);
							}
						},
						'json');
			}else{
				$.messager.alert('系统消息','请选择柜员信息进行强制柜员轧帐','error');
				return;
			}
			
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>每天的业务</strong></span>进行汇总!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style=" border-left:none;border-bottom:none; height:auto;overflow:hidden;">
				<div id="tb" style="padding:2px 0">
					<table id="tb cellpadding="0" cellspacing="0" class="tablegrid" style="width: 100%">
						<tr>
							<td class="tableleft" style="width:8%">网点编号：</td>
							<td class="tableright" style="width:17%"><input id="brchId" type="text" class="textinput" name="brch.brchId" value="${brch.brchId}"  style="cursor:pointer;" readonly="readonly" /></td>
							<td class="tableleft" style="width:8%">网点名称：</td >
							<td class="tableright" style="width:17%"><input id="brchName" type="text" class="textinput" name="brch.fullName" value="${brch.fullName}" style="cursor:pointer;" readonly="readonly" /></td>
							<td class="tableleft" style="width:8%">轧帐日期：</td>
							<td class="tableright" style="width:17%">
								<input  id="clrDate" type="text" name="clrDate" class="textinput" value="${clrDate}" readonly="readonly"/>
							<td class="tableright">
								<shiro:hasPermission name="enforceUserDayBal">
									<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-paraManage"  plain="false" onclick="enforceUserDayBal();">强制柜员轧账</a>
								</shiro:hasPermission>
								<shiro:hasPermission name="brchDayBalEnd">
									<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ok"  plain="false" onclick="tempDayBal();">轧帐</a>
								</shiro:hasPermission>
							</td>
						</tr>
					</table>
				</div>
				<table id="dg" title="柜员信息" ></table>
			
	  </div>
  </body>
</html>