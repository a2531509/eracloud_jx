<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $addDgDw;
	var $addDgDw2;
	$(function(){
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		createSysCode({
			id:"corpType2",
			codeType:"CORP_TYPE"
		});
		$addDgDw = createDataGrid({
			id:"addDgDw",
			url:"corpManager/corpManagerAction!queryCorpInfo.action",
			pagination:true,
			fit:true,
			pageSize:20,
			border:false,
			rownumbers:true,
			fitColumns:true,
			singleSelect:false,
			scrollbarSize:0,
			toolbar:"#corpSearchConts",
			columns:[[
				{field:"CUSTOMER_ID",title:"单位编号",sortable:true,minWidth:parseInt($(this).width() * 0.08)},
				{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CORP_TYPE",title:"单位类型",sortable:true,width:parseInt($(this).width() * 0.02)},
				{field:"CONTACT",title:"联系人",sortable:true,width:parseInt($(this).width() * 0.02)},
				{field:"CON_PHONE",title:"联系人电话", sortable:true,width:parseInt($(this).width() * 0.03)},
				{field:"ADDRESS",title:"地址",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CZ",title:"操作",width:30,align:'center',formatter:function(value,row,index){
					var st = "<a href='javascript:void(0);' style='width:100%;height:100%;display:block;' ";
					st += "class='czclass easyui-linkbutton' data-options=\"iconCls:'icon-add',plain:true\" ";
					st += "onclick=\"addTempRow('"  + index + "')\" >添加</a>"
					return st;
				}}
			]],
			onLoadSuccess:function(){
				$('.czclass').linkbutton({    
				    iconCls: 'icon-add'   
				}); 
				if(data.status != 0){
		    		$.messager.alert('系统消息',data.errMsg,'error');
	    	    }
			}
		});
		$addDgDw2 = createDataGrid({
			id:"addDgDw2",
			url:"cardapply/cardApplyAction!toFindCorpMsg.action?customerId=" + $("#companyNo").val(),
			pagination:false,
			fit:true,
			pageSize:20,
			border:false,
			rownumbers:true,
			fitColumns:true,
			singleSelect:false,
			scrollbarSize:0,
			queryParams:{queryType:"0"},
			toolbar:"",
			columns:[[
				{field:"CUSTOMER_ID",title:"单位编号",sortable:true,minWidth:parseInt($(this).width() * 0.08)},
				{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CORP_TYPE",title:"单位类型",sortable:true,width:parseInt($(this).width() * 0.02)},
				{field:"CONTACT",title:"联系人",sortable:true,width:parseInt($(this).width() * 0.02)},
				{field:"CON_PHONE",title:"联系人电话", sortable:true,width:parseInt($(this).width() * 0.03)},
				{field:"ADDRESS",title:"地址",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CZ",title:"操作",width:30,align:'center',formatter:function(value,row,index){
					var st = "<a href='javascript:void(0);' style='width:100%;height:100%;display:block;' ";
					st += "class='scclass easyui-linkbutton' data-options=\"iconCls:'icon-add',plain:true\" ";
					st += "onclick=\"deleteAddDgDw2('" + row.CUSTOMER_ID + "')\" >删除</a>"
					return st;
				}}
			]],
			onLoadSuccess:function(){
				$(".scclass").linkbutton({    
				    iconCls: "icon-remove"   
				});
				if(data.status != 0){
		    		$.messager.alert('系统消息',data.errMsg,'error');
	    	    }
			},
			queryParams:{
				checkFlag:"1"
			}
		});
	});
	function queryCorps() {
		$addDgDw.datagrid("load", {
			customerId:$("#corpId").val(),
			corpName:$("#corpName").val(),
			corpType:$("#corpType2").combobox("getValue"),
			checkFlag:"1",
			state:"0",
			queryType:"0"
		});
	}
	function addTempRow(index){
		var row = $addDgDw.datagrid("getRows")[index];
		$addDgDw.datagrid("loading");
		var allRows = $addDgDw2.datagrid("getRows");
		if(allRows && allRows.length > 0){
			for(var i = 0;i < allRows.length;i++){
				if(allRows[i].CUSTOMER_ID == row.CUSTOMER_ID){
					$.messager.alert("系统消息","该单位已经添加，请不要重复进行添加！","error");
					$addDgDw.datagrid("loaded");
					return;
				}
			}
		}
		$addDgDw2.datagrid("appendRow",row);
		$(".scclass").linkbutton({    
		    iconCls: "icon-remove"   
		});
		$addDgDw.datagrid("deleteRow",index);
		$addDgDw.datagrid("loaded");
		var event = window.event || arguments.callee.caller.arguments[0];
      	if (event.stopPropagation){
      		event.stopPropagation(); 
      	}else{
      		event.cancelBubble = true;
      	}
	}
	function deleteAddDgDw2(tarCorpId){
		$addDgDw2.datagrid("loading");
		var allRows = $addDgDw2.datagrid("getRows");
		if(allRows && allRows.length > 0){
			for(var i = 0;i < allRows.length;i++){
				if(allRows[i].CUSTOMER_ID == tarCorpId){
					var temoIndex = $addDgDw2.datagrid("getRowIndex",allRows[i]);
					$addDgDw2.datagrid("deleteRow",temoIndex);
				}
			}
		}
		$addDgDw2.datagrid("loaded");
	}
	function saveAllCorps(){
		var allRows = $addDgDw2.datagrid("getRows");
		var finalCorpIds = "";
		var finalCorpName = "";
		if(allRows && allRows.length > 0){
			for(var i = 0;i < allRows.length;i++){
				if(i == (allRows.length - 1)){
					finalCorpIds += allRows[i].CUSTOMER_ID;
					finalCorpName += allRows[i].CORP_NAME;
				}else{
					finalCorpIds += allRows[i].CUSTOMER_ID + ",";
					finalCorpName += allRows[i].CORP_NAME + ",";
				}
			}
		}
		$("#companyNo").val(finalCorpIds);
		$("#companyName").val(finalCorpName);
		$.modalDialog.handler.dialog("destroy");
		$.modalDialog.handler = undefined;
	}
</script>
<n:layout>
	<n:center layoutOptions="border:false" cssStyle="width:50%">
		<div id="corpSearchConts" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">单位编号：</td>
					<td class="tableright"><input id="corpId" name="corpId" class="textinput"/></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input id="corpName" name="corpName" class="textinput"/></td>
					<td class="tableleft">单位类型：</td>
					<td class="tableright">
						<input id="corpType2" name="corpType2" class="textinput" />
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="queryCorps()">查询</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="addDgDw"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:50%;border-left:none;border-bottom:none;overflow:hidden;">
		<table id="addDgDw2" title="已增加单位信息"></table>
	</div>
</n:layout>