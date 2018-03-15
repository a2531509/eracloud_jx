<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
 	var sectionData = ${sectionData};
	$(function() {
		$("#import_dialog").dialog({
			title : "新增发卡方信息",
			width : 600,
		    height : 250,
		    modal: true,
		    closed : true,
		    buttons : [
		    	 {text:"保存", iconCls:"icon-save", handler:function(){
		    		 $("#addForm").form("submit");
		    	 }},
		    	 {text:"取消", iconCls:"icon-cancel", handler:function(){
		    		 $("#import_dialog").dialog("close");
		    	 }}
		    ],
			onClose : function(){
				$("#addForm").form("reset");
			},
			onBeforeOpen : function(){
			}
		});
		$("#addForm").form({
			url:"merchantSettle/merchantSettleAction!addCardOrgBindSection.action",
			ajax:true,
			onSubmit:function(params){
				if(!$("#addForm").form("validate")){
					return false;
				}
				$.messager.progress({text:"数据处理中，请稍候...."})
			},
			success:function(data){
				$.messager.progress("close");
				var data2;
				try {
					data2 = eval("(" + data + ")");
				} catch (e) {
					jAlert("保存发卡方信息失败，" + data, "error");
					return;
				}
				if(data2.status == 1){
					jAlert("保存发卡方信息失败，" + data2.errMsg, "error");
				} else {
					jAlert("操作成功", "info", function(){
						$("#import_dialog").dialog("close");
						query();
					});
				}
			}
		});
		$.autoComplete({
			id:"addAcptId",
			text:"merchant_id",
			value:"merchant_name",
			table:"base_merchant",
			keyColumn:"merchant_id",
			optimize:true,
			minLength:"1"
		},"addAcptName");
		$.autoComplete({
			id:"addAcptName",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			keyColumn:"merchant_name",
			optimize:true,
			minLength:"1"
		},"addAcptId");
		sectionData.unshift({value:"", text:"请选择"});
		$.autoComplete({
			id:"cardOrgId",
			text:"card_org_id",
			value:"card_org_name",
			table:"card_org_bind_section",
			keyColumn:"card_org_id",
			optimize:true,
			minLength:"1"
		},"cardOrgName");
		$.autoComplete({
			id:"cardOrgName",
			text:"card_org_name",
			value:"card_org_id",
			table:"card_org_bind_section",
			keyColumn:"card_org_name",
			optimize:true,
			minLength:"1"
		},"cardOrgId");
		
		$("#state").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			editable:false,
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"正常"},
				{value:"1", text:"注销"}
			]
		});
		
		$("#bindSection").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			editable:false,
			data:sectionData
		});

		$("#dg").datagrid({
			url:"merchantSettle/merchantSettleAction!queryOrgBindSection.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			singleSelect:true,
			columns:[[
				{field:"", checkbox:true},
				{field:"BIND_SECTION",title:"卡号段",sortable:true,width:60},
				{field:"CARD_ORG_ID",title:"发卡方编号",sortable:true,width:80},
				{field:"CARD_ORG_NAME",title:"发卡方",sortable:true,width:100},
				{field:"ORG_ID",title:"登记机构",sortable:true,width:100},
				{field:"BRCH_ID",title:"登记网点",sortable:true,width:100},
				{field:"USER_ID",title:"登记柜员",sortable:true,width:100},
				{field:"LAST_MODIFY_DATE",title:"登记时间",sortable:true,width:150},
				{field:"STATE",title:"状态",sortable:true,width:60, formatter:function(value){
					if(value == "0"){
						return "正常";
					} else if(value == "1") {
						return "注销";
					} else {
						return value;
					}
				}},
				{field:"NOTE",title:"备注",sortable:true,width:100},
				{field:"ACPT_ID",title:"结算商户编号",sortable:true,width:100},
				{field:"MERCHANT_NAME",title:"结算商户",sortable:true,width:160}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
	})
	
	function query() {
		var params = getformdata("searchConts");
		params.query = true;
		$("#dg").datagrid("load", params);
	}
	
	function addItem(){
		$("#import_dialog").dialog("open");
	}
	
</script>
<n:initpage title="发卡方信息进行查询，新增操作！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">发卡方编号：</td>
						<td class="tableright"><input  id="cardOrgId" type="text" class="textinput" name="bindSection.cardOrgId" /></td>
						<td class="tableleft">发卡方名称：</td>
						<td class="tableright"><input id="cardOrgName" type="text" name="bindSection.cardOrgName" class="textinput"/></td>
						<td class="tableleft">卡号段：</td>
						<td class="tableright"><input id="bindSection" type="text" class="textinput" name="bindSection.bindSection"/></td>
						<td class="tableleft">状态：</td>
						<td class="tableright">
							<input id="state" type="text" class="textinput" name="bindSection.state"/>
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-add'" href="javascript:void(0);" class="easyui-linkbutton" onclick="addItem()">增加</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="发卡方号段信息"></table>
  		<div id="import_dialog" class="datagrid-toolbar">
  			<form id="addForm" method="post" >
		  		<table width="100%" class="tablegrid">
					<tr>
						<td class="tableleft">卡号段：</td>
						<td class="tableright" colspan="3"><input id="addBindSection" type="text" class="textinput easyui-validatebox" required="required" name="bindSection.bindSection" maxlength="2"/></td>
					</tr>
					<tr>
						<td class="tableleft">发卡方编号：</td>
						<td class="tableright"><input  id="addCardOrgId" type="text" class="textinput easyui-validatebox" required="required" name="bindSection.cardOrgId" /></td>
						<td class="tableleft">发卡方名称：</td>
						<td class="tableright"><input  id="addCardOrgName" type="text" class="textinput easyui-validatebox" required="required" name="bindSection.cardOrgName" /></td>
					</tr>
					<tr>
						<td class="tableleft">结算商户编号：</td>
						<td class="tableright"><input  id="addAcptId" type="text" class="textinput easyui-validatebox" required="required" name="bindSection.acptId" /></td>
						<td class="tableleft">结算商户名称：</td>
						<td class="tableright"><input  id="addAcptName" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">备注：</td>
						<td class="tableright" colspan="3"><textarea id="addNote" class="textinput" name="bindSection.note" style="height: 50px; width: 97%; margin-top: 3px; margin-bottom: 3px"></textarea></td>
					</tr>
				</table>
  			</form>
  		</div>
  	</n:center>
</n:initpage>