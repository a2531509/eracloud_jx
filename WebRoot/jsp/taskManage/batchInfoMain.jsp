<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $batchGrid;
	var count = 0;
	var taskNum = 0;
	var yhNum = 0;
	var num = 0;
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
		createCustomSelect({
			id:"vendorId",
			value:"vendor_id",
			text:"vendor_name",
			table:"base_vendor", 
			where:"state = '0'",
			orderby:"vendor_id asc"
		});
		$batchGrid = createDataGrid({
			id:"batchDg",
			url:"taskManagement/taskManagementAction!exportMadeCardDataQuery.action",
			border:false,
			fit:true,
			fitColumns:true,
			scrollbarSize:0,
			pageList:[50,80,100,150,200,300,500],
			singleSelect:false,
			ctrlSelect:true,
			columns:[[
			    {field:"SETTLEID",title:"id",sortable:true,checkbox:true},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_NUM",title:"任务个数",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_SUM",title:"总数量",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"YHSHTG_NUM",title:"银行审核通过数量",sortable:true},
				{field:"ISURGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BANK_ID",title:"银行编号",sortable:true,width : parseInt($(this).width() * 0.25)},
				{field:"BANK_NAME",title:"银行名称",sortable:true,width : parseInt($(this).width() * 0.25)}
			]],
			toolbar:"#batchTb",
			onLoadSuccess:function(){
                count = 0;
                taskNum = 0;
                num = 0;
                yhNum = 0;
				updateFooter();
			},
			onSelect:function(index, row){
				num += Number(row.TASK_SUM);
				taskNum += Number(row.TASK_NUM);
				yhNum += isNaN(row.YHSHTG_NUM)?0:Number(row.YHSHTG_NUM);
				count++;
				updateFooter();
			},
			onSelectAll:function(rows){
				count = 0;
				num = 0;
				taskNum = 0;
				for(var i in rows){
					num += Number(rows[i].TASK_SUM);
					taskNum += Number(rows[i].TASK_NUM);
					yhNum += isNaN(row.YHSHTG_NUM)?0:Number(rows[i].YHSHTG_NUM);
					count++;
				}
				updateFooter();
			},
			onUnselect:function(index, row){
				num -= Number(row.TASK_SUM);
				taskNum -= Number(row.TASK_NUM);
				yhNum -= isNaN(row.YHSHTG_NUM)?0:Number(row.YHSHTG_NUM);
				count--;
				updateFooter();
			},
			onUnselectAll:function(rows){
				count = 0;
				num = 0;
				taskNum = 0;
				updateFooter();
			}
		});
		var pager = $batchGrid.datagrid("getPager");
        pager.pagination({
            buttons:$("#vendorSelect")
        }); 
		$.addNumber("batchId");
	});
	function updateFooter(){
		$batchGrid.datagrid("reloadFooter", [{
			MAKE_BATCH_ID:"统计",
			CARDTYPE:"共 " + count + " 个批次",
			TASK_NUM:"共 " + taskNum + " 个任务",
			TASK_SUM:num,
			YHSHTG_NUM:yhNum
		}]);
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
				href:"jsp/taskManage/batchInfoTaskView.jsp?batchId=" + rows[0].SETTLEID ,
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
	function exportVendor(){
		var rows = $batchGrid.datagrid("getChecked");
		var batchIds = "";
		if(dealNull($("#vendorId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择接收卡厂信息！","error",function(){
				$("#vendorId").combobox("showPanel");
			});
			return;
		}
		if(rows && rows.length >= 1){
			for(var i = 0;i < rows.length;i++){
				batchIds += rows[i].MAKE_BATCH_ID;
				if(i != (rows.length - 1)){
					batchIds += ",";
				}
			}
			$.messager.confirm("系统消息","您确定要导出勾选的批次生成制卡数据信息吗？总计：" + rows.length + "个批次",function(r){
				if(r){
					$.messager.progress({text:"正在生成批次信息..."});
					$.ajax({
						url:"taskManagement/taskManagementAction!exportMadeCardDataByBatchNo.action",
						type:"post",
						dataType:"json",
						data:{batchIds:batchIds,queryType:"0","task.vendorId":$("#vendorId").combobox("getValue")},
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
<n:initpage title="制卡批次进行查询,预览,导出制卡文件数据操作！<span style='color:red'>注意；</span>导出时必须有对应的FTP配置信息！">
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
							
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="batchDg" title="批次信息"></table>
  		<div id="vendorSelect">
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
    <div id="batchWin" title="预览任务信息"></div> 
</n:initpage>