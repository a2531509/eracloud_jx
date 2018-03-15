<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 制卡任务导出,按照任务方式进行导出 -->
<script type="text/javascript">
	var $grid;
	var count = 0;
	var num = 0;
	$(function() {
		createSysBranch({
			id:"brchId"},{
			id:"operId"
		});
		$.autoComplete({
			id:"corpId",
			value:"corp_name",
			text:"customer_id",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			value:"customer_id",
			text:"corp_name",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YSC%>",
			isShowDefaultOption:false
		});
		createRegionSelect(
			{id:"regionId"},
			{id:"townId"},
			{id:"commId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_QGN %>",
			isShowDefaultOption:false
		});
		createCustomSelect({
			id:"vendorId",
			value:"vendor_id",
			text:"vendor_name",
			table:"base_vendor", 
			where:"state = '0'",
			orderby:"vendor_id asc"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action",
			border:false,
			fit:true,
			singleSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			pageList:[100,200,500,1000,2000],
			showFooter:true,
			columns:[[
				{field:"SETTLEID",title:"id",sortable:true,checkbox:true},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"TASKWAY",title:"任务组织方式",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"TASK_NAME",title:"任务名称",sortable:true},
				{field:"TASK_DATE",title:"任务时间",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width:parseInt($(this).width() * 0.08)}
			]],
			onLoadSuccess:function(){
				updateFooter();
			},
			onSelect:function(index, row){
				num += Number(row.TASK_SUM);
				count++;
				updateFooter();
			},
			onSelectAll:function(rows){
				count = 0;
				num = 0;
				for(var i in rows){
					num += Number(rows[i].TASK_SUM);
					count++;
				}
				updateFooter();
			},
			onUnselect:function(index, row){
				num -= Number(row.TASK_SUM);
				count--;
				updateFooter();
			},
			onUnselectAll:function(rows){
				count = 0;
				num = 0;
				updateFooter();
			}
		});
		var pager = $grid.datagrid("getPager");
        pager.pagination({
            buttons:$("#zhuguanPwdDiv")
        }); 
		$.addNumber("makeBatchId");
		$.addNumber("taskId");
		$.addNumber("corpId");
	});
	
	function updateFooter(){
		$grid.datagrid("reloadFooter", [{
			TASK_ID:"统计",
			MAKE_BATCH_ID:"共 " + count + " 个任务",
			TASK_SUM:num
		}]);
	}
	function toQuery(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	function autoSelectByBatch(index,rowData){
		var allDatas = $grid.datagrid("getRows");
		var batchId = rowData.MAKE_BATCH_ID;
		if(allDatas && allDatas.length > 0){
			for(var i = 0;i < allDatas.length;i++){
				var tempRow = allDatas[i];
				var tempRowIndex = $grid.datagrid("getRowIndex",tempRow);
				if(tempRow.MAKE_BATCH_ID == batchId){
					$grid.datagrid("checkRow",tempRowIndex);
				}else{
					$grid.datagrid("uncheckRow",tempRowIndex);
				}
			}
			$grid.datagrid("checkRow",index);
		}
	}
	function autoUnSelect(index,rowData){
		var row = $grid.datagrid("getSelected");
		if(row){
			if(row.SETTLEID == rowData.SETTLEID){
				
			}else{
				$grid.datagrid("unselectAll");
				$grid.datagrid("checkRow",index);
			}
		}else{
			$grid.datagrid("unselectAll");
		}
	}
	function viewTaskList(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$.messager.progress({text:"正在加载，请稍后...."});
			$("#taskListViewWin").window({
				title:"预览任务明细",
				iconCls:"icon-viewInfo",
				shadow:false,
				border:false,
				maximized:true,
				shadow:false,
				closable:false,
				maximizable:false,
				minimizable:false,
				closable:false,
			    collapsed:false,
				collapsible:false,
				href:"jsp/taskManage/viewCardTask.jsp?taskId=" + rows[0].SETTLEID + "&taskState=" + rows[0].TASK_STATE +
						"&taskStateName=" + escape(encodeURIComponent(rows[0].TASKSTATE)) + "&taskWay=" + rows[0].TASK_WAY +
						"&tempTaskWay=<%=com.erp.util.Constants.TASK_WAY_WD%>" + "&tempTaskState=<%=com.erp.util.Constants.TASK_STATE_YSC%>" ,
				tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						$.messager.progress("close");
						$("#taskListViewWin").window("close");
				    }
				}]
			});
		}else{
			$.messager.alert("提示信息","请选择一条记录进行预览","error");
		}
	}
	function exportVendor(){
		var vendorId = $("#vendorId").combobox("getValue");
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(!rows || rows.length <= 0){
			$.messager.alert("系统消息","请勾选将要进行导出的任务记录信息！","error");
			return;
		}
		if(dealNull(vendorId) == ""){
			$.messager.alert("系统消息","请选择制卡卡商信息！","error",function(){
				$("#vendorId").combobox("showPanel");
			});
			return false;
		}
		for(var i = 0;i < rows.length;i++){
			if(rows[i].TASK_STATE != <%=com.erp.util.Constants.TASK_STATE_YSC%>){
				$.messager.alert("系统消息","任务编号为【" + rows[i].SETTLEID + "】的任务状态不为【任务已生成】！","error");
				return;
			}
			if(i == rows.length - 1){
				taskIds = taskIds + rows[i].SETTLEID;
			}else{
				taskIds = taskIds + rows[i].SETTLEID + "|";
			}
		}
		$.messager.confirm("系统消息","您确定要将勾选的任务导出给【" + $("#vendorId").combobox("getText") + "】进行制卡吗？",function(is){
			if(is){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.ajax({
					dataType:"json",
					global:true,
					url:"taskManagement/taskManagementAction!exportMadeCardData.action",
				    data:{
				    	"task.vendorId":$("#vendorId").combobox("getValue"),
				    	taskIds:taskIds
				    },
					success:function(rsp){
						$.messager.progress("close");
						if(dealNull(rsp.status) == "0"){
							$.messager.alert("系统消息",rsp.errMsg,"info",function(){
								toQuery();
							});
						}else{
							$.messager.alert("系统消息",rsp.errMsg,"error");
						}
					}
				});
			}
		});
	}
</script>
<n:initpage title="制卡数据进行导出操作！<span style='color:red'>注意：</span>只有任务状态为【银行已审核】的任务才能进行制卡数据导出操作，导出时必须按照整批次导出，不能单独任务导出！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="task.cardType" type="text"  class="textinput"/></td>
					</tr>
					<tr>
	                    <td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="task.corpId" type="text" class="textinput"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright" ><input id="corpName" name="corpName" type="text" class="textinput"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
					    <td class="tableleft">任务网点：</td>
						<td class="tableright"><input id="brchId" name="task.taskBrchId"  type="text" class="textinput"/></td>
						<td class="tableleft">任务柜员：</td>
						<td class="tableright"><input id="operId" name="task.taskOperId" type="text" class="textinput"/></td>
					    <td class="tableleft">所在城区：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">所在乡镇：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">社区(村)：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
						<td class="tableleft" colspan="6" style="padding-right: 3%">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false" onclick="viewTaskList();">任务预览</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
  		<div id="zhuguanPwdDiv">
            <table>
                <tr> 
				  	<shiro:hasPermission name="cardOnlyTaskExpToBank">
						<td align="right">&nbsp;&nbsp;卡厂：</td>
		 				<td>
		 					<input id="vendorId" name="vendorId" type="text" class="easyui-combobox"  style="width:124px;"/>
		 					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="exportVendor();">导出卡厂</a>
		 				</td>
  				 	</shiro:hasPermission>
                 </tr>
            </table>
        </div> 
    </n:center>
    <div id="taskListViewWin"></div>
</n:initpage>