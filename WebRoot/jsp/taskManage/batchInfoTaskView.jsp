<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var $grid;
	$(function() {
		createSysCode({id:"taskState",codeType:"TASK_STATE"});
		createRegionSelect(
			{id:"regionId"},
			{id:"townId"},
			{id:"commId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_SMZK %>",
			isShowDefaultOption:false
		});
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action?task.makeBatchId=${param.batchId}",
			border:false,
			fit:true,
			fitColumns: true,
			scrollbarSize:0,
			pageList:[50,80,100,150,200,300,500],
			queryParams:{queryType:"0"},
			columns:[[   
			    {field:"SETTLEID",title:"id",sortable:true,checkbox:true},
				{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width : parseInt($(this).width() * 0.3)},
				{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width : parseInt($(this).width() * 0.08)}
			]]
		});
		$.addNumber("corpId");
	});
	function toQuery(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	function viewTaskList(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.messager.progress({text:"正在加载，请稍后...."});
			$.modalDialog({
				title:"预览任务明细",
				iconCls:"icon-viewInfo",
				shadow:false,
				border:false,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				href:"jsp/taskManage/viewCardTask.jsp?taskId=" + rows[0].SETTLEID + "&taskState=" + rows[0].TASK_STATE +
						"&taskStateName=" + escape(encodeURIComponent(rows[0].TASKSTATE)) + "&taskWay=" + rows[0].TASK_WAY +
						"&tempTaskWay=<%=com.erp.util.Constants.TASK_WAY_WD%>" + "&tempTaskState=<%=com.erp.util.Constants.TASK_STATE_YSC%>" ,
				tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						$.messager.progress("close");
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
				    }
				}]/* ,
					buttons:[
					{
						iconCls:"icon_cancel_01",
						text:"关闭",
						handler:function(){
							$.messager.progress("close");
							$.modalDialog.handler.dialog("destroy");
							$.modalDialog.handler = undefined;
					    }
					}
				] */
			});
		}else{
			$.messager.alert("提示信息","请选择一条记录进行预览","error");
		}
	}
</script>
<n:layout>
	<n:center layoutOptions="border:false">
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" maxlength="20"/></td>
	                    <td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="task.corpId" type="text" class="textinput"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input id="corpName" name="corpName" type="text" class="textinput"/></td>
						<td>&nbsp;</td>
					</tr>
					<tr>
					    <td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">乡镇（街道）：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区(村)：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
						<td style="text-align:center;" colspan="2">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false" onclick="viewTaskList();">任务预览</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg"></table>
    </n:center>
</n:layout>