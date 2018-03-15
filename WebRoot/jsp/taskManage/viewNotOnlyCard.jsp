<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $gridview;
	$(function(){
		$gridview = createDataGrid({
			id:"dgview",
			url:"taskManagement/taskManagementAction!viewFgxhCg.action?taskList.taskId=${param.taskId}" ,
			border:false,
			fit:true,
			fitColumns:true,
			singleSelect:false,
			queryParams:{queryType:"0"},
			scrollbarSize:0,
			pageSize:20,
			columns:[[
			    //{field:"ID",checkbox:true},
			    {field:"DATA_SEQ",title:"采购流水编号",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.11)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.13)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"BUSTYPE",title:"公交类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BURSESTARTDATE",title:"电子钱包启用日期",sortable:true,width:parseInt($(this).width()* 0.09)},
				{field:"BURSEVALIDDATE",title:"电子钱包有效期",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"HLHT_FLAG",title:"互联互通标识",sortable:true,width:parseInt($(this).width()* 0.08)},
				{field:"TOUCH_STARTDATE",title:"接触式启用日期",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"TOUCH_VALIDDATE",title:"接触式有效期",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
			toolbar:"#tbview",
            onLoadSuccess:function(data){
            	$("input[type='checkbox']").each(function(){if(this.checked){this.checked = false;}});
            	if(data.status != 0){
            	 	$.messager.alert("系统消息",data.errMsg,"error");
            	}
            }
		});
	});
	function toQueryTaskList(){
		var params = getformdata("viewSearchConts");
		params["queryType"] = "0";
		$gridview.datagrid("load",params);
	}
</script>
<n:layout>
	<n:center cssStyle="border:none">
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:7%;">流水号：</td>
						<td class="tableright" style="width:18%;"><input id="dataSeq" name="taskList.dataSeq" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft" style="width:7%;">卡号：</td>
						<td class="tableright" style="width:18%;"><input id="cardNo" name="taskList.cardNo" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableright" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTaskList()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	  	<table id="dgview"></table>
	</n:center>
</n:layout>