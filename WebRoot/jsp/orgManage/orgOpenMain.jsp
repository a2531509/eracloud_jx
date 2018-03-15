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
    <title>机构账户开户</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			//查询条件证件类型
			$querycerttype = $("#orgType").combobox({
				width:174,
				url:"/sysCode/sysCodeAction!findSysCodeListByType.action?codeType=ORG_TYPE",
				valueField:'codeValue',
				editable:false, //不可编辑状态
			    textField:'codeName',
			    panelHeight: 'auto',//自动高度适合
			    value:'1',
			    onSelect:function(node){
			 		$("#orgType").val(node.text);
			 	}
			});
			
			$("#itemIdRow").combobox({
				width:174,
				url:"/sysOrgan/sysOrganAction!findItemInfo.action",
				valueField:'itemId',
				editable:false, //不可编辑状态
			    textField:'itemName',
			    panelHeight: '200',//自动高度适合
			    onSelect:function(node){
			 		$("#itemIdRow").val(node.text);
			 	}
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/sysOrgan/sysOrganAction!findOrgAndAccInfo.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:false,
				rownumbers:true,
				border:true,
				striped:true,
				autoRowHeight:true,
				//0未启用1正常2口头挂失3书面挂失9注销
				columns : [ [ {idField : 'orgId',hidden:true},
				              {field : 'itemId',title : '科目号',width : parseInt($(this).width() * 0.1),sortable:true},
				              {field : 'itemName',title : '科目名称',width : parseInt($(this).width()*0.1),sortable:true},
				              {field : 'accName',title : '户名',width : parseInt($(this).width()*0.15),sortable:true},
				              {field : 'accState',title : '状态',width:80,formatter:function(value,row){
				            	  if(value == '1'){
				            		  return '正常';
				            	  }else{
				            		  return '注销';
				            	  }
				              }}
				              ]],toolbar:'#tb',
				              onLoadSuccess:function(data){
				            	  if(data.status != 0){
				            		 $.messager.alert('查询信息失败',data.errMsg,'error');
				            	  }
				              }
			});
		});
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				orgId:$("#orgType").combobox('getValue'), 
				accNo:$('#accNo').val(), 
				orgId:$('#orgId').val(),
				orgName:$('#orgName').val()
			});
		}
		//提交表单
		function submitForm(){
			var curRow = $dg.datagrid("getSelected");
			if(!curRow){
				$.messager.alert('服务密码修改','请至少选择一条记录进行服务密码修改！','error');
				return;
			}
			//已选择记录
			if($('#oldPwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('服务密码修改','请输入原始密码','error');
				return;
			}
			if($('#pwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('服务密码修改','请输入新密码','error');
				return;
			}
			if($('#confirmPwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('服务密码修改','请输入确认密码','error');
				return;
			}
			if($('#pwd').val().replace(/\s/g,'') != $('#confirmPwd').val().replace(/\s/g,'')){
				$.messager.alert('服务密码修改','新密码和确认密码不相同！请重新输入','error',function(){
					$('#confirmPwd').val('');
					$('#confirmPwd').focus();
				});
				return;
			}
			var customerId = curRow.customerId;
			$.post('/pwdservice/pwdserviceAction!saveServicePwd.action',$("#form").serialize() + "&customerId=" + customerId,function(data,status){
				if(status == 'success'){
					$.messager.alert('服务密码修改',data.message,(data.status ? 'info' :'error'),function(){
						$('#oldPwd').val('');
						$('#pwd').val('');
						$('#confirmPwd').val('');
						if(data.status){
							showCurrentPdf('服务密码修改');
						}
					});
				}else{
					$.messager.alert('服务密码修改','服务密码修改失败！','error');
				}
			},'json');
		}
	</script>
	<style>
		.textinput{
			height: 18px;
			width: 170px;
			line-height: 16px;
		    /*border-radius: 3px 3px 3px 3px;*/
		    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
		    transition: border 0.2s linear 0s, box-shadow 0.2s linear 0s;
		}
		
		textarea:focus, input[type="text"]:focus{
		    border-color: rgba(82, 168, 236, 0.8);
		    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset, 0 0 8px rgba(82, 168, 236, 0.6);
		    outline: 0 none;
			}
			table {
		    background-color: transparent;
		    border-collapse: collapse;
		    border-spacing: 0;
		    max-width: 100%;
		}
	
		fieldset {
		    border: 0 none;
		    margin: 0;
		    padding: 0;
		}
		legend {
		    -moz-border-bottom-colors: none;
		    -moz-border-left-colors: none;
		    -moz-border-right-colors: none;
		    -moz-border-top-colors: none;
		    border-color: #E5E5E5;
		    border-image: none;
		    border-style: none none solid;
		    border-width: 0 0 1px;
		    color: #999999;
		    line-height: 20px;
		    display: block;
		    margin-bottom: 10px;
		    padding: 0;
		    width: 100%;
		}
		input, textarea {
		    font-weight: normal;
		}
		test table ,th,td{
			text-align:left;
			padding: 6px;
		}
	</style>
  </head>
  <body>
  <div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>机构</strong></span>进行开户!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td style="padding-left:2px">机构类型：</td>
						<td style="padding-left:2px"><input id="orgType" type="text" class="easyui-combobox  easyui-validatebox" name="orgType"  style="width:174px;cursor:pointer;"/></td>
						<td style="padding-left:2px">账号：</td>
						<td style="padding-left:2px"><input name="accNo"  class="textinput" id="accNo" type="text" /></td>
						<td style="padding-left:2px">机构编号：</td>
						<td style="padding-left:2px"><input id="orgId" type="text" class="textinput  easyui-validatebox" name="orgId" style="width:174px;"/></td>
						<td style="padding-left:2px">机构名称：</td>
						<td style="padding-left:2px"><input name="orgName"  class="textinput" id="orgName" type="text" /></td>
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="机构账户信息"></table>
	  </div>
	  <div id="test" data-options="region:'south',split:false,border:true" style="height:200px; width:auto;overflow:hidden;text-align:center;">
	  		<form id="form" method="post">
				<fieldset>
					<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>机构账户开户</legend>
					 <table style="width:100%;">
						 <tr>
						 	<th>机构名称：</th>
							<td ><input id="orgNameRow"  class="textinput easyui-validatebox" name="orgNameRow" style="width:174px;" maxlength="6"/></td>
						 	<th>机构号：</th>
							<td ><input id="orgIdRow"  class="textinput easyui-validatebox" name="orgIdRow" style="width:174px;" maxlength="6"/></td>
							<th>科目：</th>
							<td><input name="itemIdRow" class="easyui-combobox easyui-validatebox" id="itemIdRow" /></td>
							<th>账号：</th>
							<td ><input id="accNoRow" type="text" class="textinput  easyui-validatebox" name="accNoRow"  style="width:174px;"/></td>
						</tr>
						<tr>
							<th>备注</th>
							<td colspan="7"><textarea class="textinput" id="note" name="note"  style="width: 515px;height: 60px;"></textarea></td>
						</tr>
						<tr>
							<td height="50px" colspan="8" style="text-align:center;">
								<a style="text-align:center;margin:0 auto;" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="submitForm()">开户</a>
							</td>
						</tr>
					 </table>
				</fieldset>
			</form>			
	  </div>
	</div>
  </body>
</html>
