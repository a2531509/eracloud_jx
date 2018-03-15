<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $batchGrid;
	$(function() {
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_SMZK %>",
			isShowDefaultOption:false
		});
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		$.addNumber("batchId");
		$batchGrid = createDataGrid({
			id:"batchDg",
			url:"taskManagement/taskManagementAction!exportBankBkFileQuery.action",
			border:false,
			fit:true,
			fitColumns:true,
			singleSelect:false,
			pageList:[50, 100, 200, 300, 500, 1000],
			showFooter:true,
			columns:[[
			    {field:"SETTLEID",checkbox:true},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_NUM",title:"任务个数",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_SUM",title:"总数量",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"END_SUM",title:"制卡数量",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"ISURGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BANK_ID",title:"银行编号",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"BANK_NAME",title:"银行名称",sortable:true,width : parseInt($(this).width() * 0.2)}
			]],
			onLoadSuccess:function(data){
				if(data.status == "1"){
					jAlert(data.errMsg, "warning");
				}
				updateFooter();
			},
			onSelect:updateFooter,
			onUnselect:updateFooter,
			onSelectAll:updateFooter,
			onUnselectAll:updateFooter,
			toolbar:"#batchTb"
		});
	});
	function updateFooter(){
		var batchNum = 0;
		var taskNum = 0;
		var taskSum = 0;
		var endSum = 0;
		var selections = $("#batchDg").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				batchNum++;
				taskNum += Number(selections[i].TASK_NUM);
				taskSum += Number(selections[i].TASK_SUM);
				endSum += Number(selections[i].END_SUM);
			}
		}
		$("#batchDg").datagrid("reloadFooter", [{MAKE_BATCH_ID : "共 " + batchNum + " 个批次", TASK_NUM : taskNum, TASK_SUM : taskSum, END_SUM : endSum}]);
	}
	function toQueryBatch(){
		var params = getformdata("searchContsBatch");
		params["queryType"] = "0";
		$batchGrid.datagrid("load",params);
	}
	function viewTask(){
		var rows = $batchGrid.datagrid("getChecked");
		if(rows && rows.length == 1){
			$("#batchWin").window({  
				href:"jsp/taskManage/batchInfoTaskView.jsp?batchId=" + rows[0].SETTLEID,
			    width:600,   
			    fit:true,
			    height:400,    
			    closable:false,
			    minimizable:false,
			    collapsed:false,
				maximizable:false,
				collapsible:false,
			    iconCls:"icon-viewInfo",
			    maximized:true,
			    modal:true,
			    maximized:true,
			    tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						$("#batchWin").window("close");
				    }
			    }]
			});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行预览","error");
		}
	}
	function exportBkFile(){
		var rows = $batchGrid.datagrid("getChecked");
		var batchIds = "";
		if(rows && rows.length >= 1){
			for(var i = 0;i < rows.length;i++){
				batchIds += rows[i].MAKE_BATCH_ID + "|" + rows[i].BANK_ID;
				if(i != (rows.length - 1)){
					batchIds += ",";
				}
			}
			$.messager.confirm("系统消息","您确定要导出勾选的批次生成市民卡银行卡号对应关系供银行开户吗？总计：" + rows.length + "个批次",function(r){
				if(r){
					$.messager.progress({text:"正在生成市民卡银行卡号对应关系数据..."});
					$.ajax({
						url:"taskManagement/taskManagementAction!saveExportBankBkFile.action",
						type:"post",
						dataType:"json",
						data:{batchIds:batchIds},
						timeout:0,
						async:true,
						success:function(data){
							if(data["status"] == "0"){
								$.messager.alert("系统消息",data["errMsg"],"info",function(){
									$batchGrid.datagrid("reload");
								});
							}else{
								$.messager.alert("系统消息",data["errMsg"],"error");
							}
						},
						error:function(XMLHttpRequest, textStatus, errorThrown){
							$.messager.alert("系统消息",textStatus,"error");
						},
						complete:function(XMLHttpRequest,textStatus){
							$.messager.progress("close");
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请至少勾选一个批次进行导出！","error");
		}
	}
</script>
<n:initpage title="制卡批次进行查询,预览,导出市民卡银行卡号对应关系数据操作！<span style='color:red'>注意；</span>1、只有【已制卡】的批次才能进行导出操作；2、导出时必须有对应的FTP配置信息！">
	<n:center>
		<div id="batchTb">
			<form id="searchContsBatch">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="batchId" name="batch.batchId" type="text" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入制卡批次号',invalidMessage:'请输入制卡批次号'" maxlength="10"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="batch.cardType" type="text"  class="textinput"/></td>
						<td class="tableleft">审核银行：</td>
						<td class="tableright">
							<input id="bankId" name="batch.bankId" type="text" class="textinput easyui-validatebox" data-options="required:true,validType:'email',missingMessage:'接收审核数据的银行',invalidMessage:'接收审核数据的银行'" maxlength="15"/>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:false"   onclick="toQueryBatch()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-viewInfo',plain:false"   onclick="viewTask()">预览</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-export',plain:false"   onclick="exportBkFile()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="batchDg" title="批次信息"></table>
    </n:center>
    <div id="batchWin" title="预览任务信息"></div>
</n:initpage>