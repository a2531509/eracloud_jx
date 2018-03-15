<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<style>
	.tablegrid th{font-weight:700}
	#dw option{height:28px;}
</style>
<script type="text/javascript">
	$(function(){
		$("#customerType").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CUSTOMER_TYPE",
			valueField:"codeValue",
			textField:"codeName",
			editable:true,
			panelHeight: 'auto',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$("#accKind").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=ACC_KIND",
			valueField:"codeValue",
			textField:"codeName",
			editable:false,
			panelHeight: 'auto',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$("#accState").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=ACC_STATE",
			valueField:"codeValue",
			textField:"codeName",
			editable:false,
			panelHeight: 'auto',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$.post("paraManage/itemManageAction!findBaiscItemAllList.action?queryType=0", {item_id:$("#itemId").val()}, function(data){
			if(data && $("#itemId").val() != ""){
				var item = data.rows[0];
				$("#itemId").textbox("setValue", item.ITEM_NAME);
			}
		}, "json");
	});

	function save(){
		$.messager.progress({text:"数据处理中，请稍候..."});
		$("#form").form('submit',{
			url:"corpManager/corpManagerAction!corpCashAccRecharge.action",
			onSubmit:function(){
				if(!$("#form").form("validate")){
					return false;
				}
			},
			success:function(resData){
				$.messager.progress("close");
				var data = JSON.parse(resData);
				if(data.status == "1"){
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					showReport("单位充值",data.dealNo, function(){
						$.modalDialog.handler.dialog('destroy');
						$.modalDialog.handler = undefined;
					});
				}
			}
		});
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false,fit:true" title="" style="overflow: hidden;padding:0px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<input type="hidden" id="customerId" name="customerId" value="${corpAccount.customerId}"/>
			<h3 class="subtitle">单位账户信息</h3>
			<table class="tablegrid" style="width:100%">
				 <tr>
				    <th class="tableleft" style="width:15%">客户名称：</th>
					<td class="tableright" style="width:25%"><input id="mainType" type="text"  class="easyui-textbox" value="${corpName}" disabled="disabled"/></td>
				 	<th class="tableleft"  style="width:25%">客户类型：</th>
					<td class="tableright" style="width:35%"><input id="customerType"  type="text" class="textinput" value="${corpAccount.customerType}" disabled="disabled"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">账户种类：</th>
					<td class="tableright"><input id="accKind" type="text" class="textinput" value="${corpAccount.accKind}" disabled="disabled"/></td>
					<th class="tableleft">账户科目：</th>
					<td class="tableright" ><input id="itemId" type="text" class="easyui-textbox" value="${corpAccount.itemId}" disabled="disabled"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">总余额/元：</th>
					<td class="tableright"><input id="accBal" value="${corpAccount.bal / 100}" class="easyui-textbox" type="text" disabled="disabled"/></td>
					<th class="tableleft">账户状态：</th>
					<td class="tableright"><input id="accState" type="text" class="textinput" value="${corpAccount.accState}" disabled="disabled"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">充值金额/元：</th>
					<td class="tableright"><input id="amount" name="amount" class="textinput easyui-validatebox" data-options="required:true" type="number" placeholder="请输入充值金额"/></td>
				 </tr>
			 </table>
		</form>
	</div>
</div>