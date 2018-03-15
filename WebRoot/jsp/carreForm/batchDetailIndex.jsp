<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@taglib uri="http://shiro.apache.org/tags"  prefix="shiro"%>
<style>
table td {
	padding: 0 10px;
}
</style>
<script type="text/javascript">
	$(function() {
		$("#state2").combobox({
			labelField : "value",
			textField : "name",
			panelHeight : "auto",
			editable : false,
			data : [
				{value:"", name:"请选择"},
				{value:"0", name:"未确认"},
				{value:"1", name:"审核不通过"},
				{value:"2", name:"已确认"},
				{value:"3", name:"充值失败"},
				{value:"5", name:"已充值"},
				{value:"6", name:"已补充值"}
			]
		});
		
		$("#dg2").datagrid({
			url : "payCarreForm/payCarreFormAction!queryBatchDetails.action?",
			pagination : true,
			fit : true,
			toolbar : $("#tb2"),
			pageSize : 20,
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			singleSelect : true,
			columns : [ [
			    {field:"", checkbox:true},
				{field:"BATCH_NUMBER", title:"批次号", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"PROVIDE_YEAR", title:"年份", sortable:true, width : parseInt($(this).width() * 0.03)},
				{field:"PROVIDE_MONTH", title:"月份", sortable:true, minWidth : parseInt($(this).width() * 0.03)},
				{field:"EMP_NAME", title:"单位名称", sortable:true, width : parseInt($(this).width() * 0.12)},
				{field:"CERT_NO", title:"身份证号码", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"NAME", title:"姓名", sortable:true, width : parseInt($(this).width() * 0.04)},
				{field:"CARD_NO", title:"卡号", sortable:true, width : parseInt($(this).width() * 0.11)},
				{field:"AMT", title:"发放金额", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"STATE", title:"状态", sortable:true, width : parseInt($(this).width() * 0.04), formatter:function(value){
					if (value == "0"){
						return "<span style='color:orange'>未确认</span>";
					} else if (value == "1"){
						return "<span style='color:red'>审核不通过</span>";
					} else if (value == "2"){
						return "<span style='color:black'>已确认</span>";
					} else if (value == "3"){
						return "<span style='color:red'>充值失败</span>";
					} else if (value == "5"){
						return "<span style='color:green'>已充值</span>";
					} else if (value == "6"){
						return "<span style='color:blue'>已补充值</span>";
					}
				}},
				{field:"RECHG_DATE", title:"充值时间", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"RECHG_ACTION_NO", title:"充值流水", sortable:true, minWidth : parseInt($(this).width() * 0.04)},
				{field:"FAILURE_REASON", title:"失败原因", sortable:true, width : parseInt($(this).width() * 0.08)},
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'error');
				}
			},
			queryParams : {
				
			},
			onBeforeLoad : function(param){
				param["payCarreform.id.batchNumber"] = "${payCarTotal.batchNumber}";
			}
		});
	})
	
	function query2(){
		$("#dg2").datagrid("load", {
			"payCarreform.id.certNo":$("#certNo2").val(),
			"payCarreform.cardNo":$("#cardNo2").val(),
			"payCarreform.name":$("#name2").val(),
			"payCarreform.state":$("#state2").combobox("getValue"),
		});
	}
	
	function edit2(){
		var selection = $("#dg2").datagrid("getSelections");
		
		if(selection.length != 1){
			$.messager.alert("消息提示", "请选择一条记录", "info");
			return;
		}
		
		if(selection[0].STATE >= "4"){
			$.messager.alert("消息提示", "充值记录[已充值], 不能修改", "info");
			return;
		}
		
		$("#editDialog2").dialog({
			title: '修改车改充值信息',    
		    width: 600,    
		    height: 250,    
		    closed: false,    
		    cache: false,    
		    href: "payCarreForm/payCarreFormAction!editPayCarreFormPage.action?payCarreform.id.batchNumber=" + selection[0].BATCH_NUMBER + "&payCarreform.id.certNo=" + selection[0].CERT_NO,    
		    modal: true,
		    buttons:[{
				text:'保存',
				iconCls:'icon-ok',
				handler:function(){
					save3();
					isEdit = true;
				}
			},{
				text:'返回',
				iconCls:'icon-cancel',
				handler:function(){
					$("#editDialog2").dialog("close");
				}
			}]
		});
	}
</script>
<div class="easyui-layout" data-options="fit:true">
	<div data-options="region:'center',split:false,border:false"
		style="height: auto; overflow: hiddsen;">
		<div id="tb2" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<td class="tableleft">身份证号：</td>
					<td class="tableright"><input id="certNo2"
						class="textinput" /></td>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input id="cardNo2" class="textinput" /></td>
					<td class="tableleft">姓名：</td>
					<td class="tableright"><input id="name2" class="textinput" /></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input id="state2" class="textinput" /></td>
				</tr>
			</table>
			<div style="padding: 2px 20px; border: 1px dotted rgb(149, 184, 231); border-top: none;">
				<a href="javascript:void(0);" class="easyui-linkbutton"
					iconCls="icon-search" onclick="query2()">查询</a>
				<shiro:hasPermission name="modifyPayCarreFormList">
					<a href="javascript:void(0);" class="easyui-linkbutton"
						iconCls="icon-edit" onclick="edit2()">编辑</a>
				</shiro:hasPermission>
			</div>
		</div>
		<table id="dg2"
			title="车改批量充值明细[${payCarTotal.batchNumber}]"></table>
	</div>
	<div id="editDialog2"></div>
</div>