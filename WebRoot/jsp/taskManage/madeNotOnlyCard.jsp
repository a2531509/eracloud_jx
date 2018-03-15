<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
    var totTaskNums = 0;
    var totNums = 0;
	$(function() {
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YSC%>,<%=com.erp.util.Constants.TASK_STATE_ZKZ%>,<%=com.erp.util.Constants.TASK_STATE_YJS%>",
			isShowDefaultOption:false
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_JMK_BCP%>,<%=com.erp.util.Constants.CARD_TYPE_FJMK%>,<%=com.erp.util.Constants.CARD_TYPE_FJMK_XS%>",
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
			id:"regionId",
			value:"region_id",
			text:"region_name || '【' || region_code || '】'",
			table:"base_region",
			where:"region_state = '0' ",
			orderby:"region_id asc",
			missingMessage:"采购所属区域",
			invalidMessage:"采购所属区域",
			required:true,
			validType:"email"
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
			url:"taskManagement/taskManagementAction!fgxhcgQuery.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			scrollbarSize:0,
			autoRowHeight:true,
			ctrlSelect:true,
			singleSelect:false,
			frozenColumns:[[
			    {field:"SETTLEID",title:"id",checkbox:"ture"},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width:parseInt($(this).width() * 0.3)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.12)}
			]],
			columns:[[
				{field:"TASK_DATE",title:"任务时间",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"REGION_NAME",title:"区域",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"TASK_SUM",title:"任务数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"IS_URGENT",title:"制卡方式",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"BANK_NAME",title:"银行名称",sortable:true,width:parseInt($(this).width() * 0.06)}
            ]],
            onLoadSuccess:function(data){
                if(data.status != 0){
                    $.messager.alert("系统消息",data.errMsg,"error");
                    return;
                }
                initCal();
                updateFooter();
            },
            onCheck:function(index,data){
                calRow(true,data);
                updateFooter();
            },
            onUncheck:function(index,data){
                calRow(false,data);
                updateFooter();
            },
            onCheckAll:function(rows){
                initCal();
                for(var i=0,hk=rows.length;i < hk;i++){
                    var data  = rows[i];
                    calRow(true,data);
                }
                updateFooter();
            },
            onUncheckAll:function(rows){
                initCal();
                updateFooter();
            }
		});
		$.addNumber("makeBatchId");
		$.addNumber("taskId");
	});
	function query(){
		var param = getformdata("searchConts");
		param["queryType"] = "0";
		param["taskStartDate"] = $("#taskStartDate").val();
		param["taskEndDate"] = $("#taskEndDate").val();
		$grid.datagrid("load",param);
	}
	function addNotOnlyTask() {
		parent.$.modalDialog({
			title:"非个性化卡采购新增",
			width:780,
			height:200,
			closable:false,
			iconCls:"icon-add",
			href:"jsp/taskManage/notOnlyCardTaskAdd.jsp",
			tools:[{
		    	iconCls:"icon_cancel_01",
				handler:function(){
					parent.$.modalDialog.handler.dialog("destroy");
					parent.$.modalDialog.handler = undefined;
			    }
			}],
			buttons:[ {
				text:"保存",
				iconCls:"icon-ok",
				handler:function() {
					parent.saveCg($grid);
				}
			}, {
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					parent.$.modalDialog.handler.dialog("destroy");
					parent.$.modalDialog.handler = undefined;
				}
			}
			]
		});
	}
	function delNotOnlyTask(){
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(rows && rows.length > 0){
			for(var i = 0;i < rows.length;i++){
				taskIds += rows[i].TASK_ID;
				if(i != (rows.length - 1)){
					taskIds += ",";
				}
			}
			$.messager.confirm("系统消息","您确定要删除勾选的非个性化卡制卡采购任务信息吗？",function(r){
				if(r){
					$.messager.progress({text:"正在删除采购任务信息，请稍候..."});
					$.ajax({
						url:"taskManagement/taskManagementAction!deleteFgxhCg.action",
						data:{taskIds:taskIds},
						dataType:"json",
						success: function(rsp){
							if(rsp["status"] == "0"){
								$.messager.alert("系统消息","采购任务删除成功！","info",function(){
									$grid.datagrid("reload");
								});
							}else{
								$.messager.alert("系统消息",rsp["errMsg"],"error");
							}
						},
						complete:function(xhq,textStatus){
							$.messager.progress("close");
						},
						error:function(XMLHttpRequest,textStatus,errorThrown){
							
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请至少勾选一条任务记录进行删除！","error");
		}
	}
	function viewNotOnlyTask(){
		var rows = $grid.datagrid("getChecked");
		if (rows && rows.length == 1) {
			$.modalDialog({
				title:"非个性化卡采购预览",
				width:780,
				height:200,
				maximized:true,
				closable:false,
				iconCls:"icon-viewInfo",
				href:"jsp/taskManage/viewNotOnlyCard.jsp?taskId=" + rows[0].TASK_ID,
				tools:[{
			    	iconCls:"icon_cancel_01",
					handler:function(){
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
				    }
				}]
			});
		}else{
			$.messager.alert("系统消息","请勾选一条任务记录进行预览！","error");
		}
	}
	function expNotOnlyTask(){
		if(dealNull($("#vendorId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择导出卡厂信息！","error",function(){
				$("#vendorId").combobox("showPanel");
			});
			return;
		}
		var tempCardType = "";
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(rows && rows.length > 0) {
			for(var i = 0;i < rows.length;i++){
				taskIds += rows[i].TASK_ID;
                if(tempCardType != "" && tempCardType != rows[i].CARDTYPE){
                    jAlert("请选择同一种非个性化采购卡类型进行导出！","warning");
                    return;
                }
                tempCardType = rows[i].CARDTYPE;
				if(i != (rows.length - 1)){
					taskIds += ",";
				}
			}
			$.messager.confirm("系统消息","您确定要导出勾选的非个性化卡制卡采购任务信息吗？",function(r){
				if(r){
					$.messager.progress({text:"正在导出采购任务信息，请稍候..."});
					$.ajax({
						url:"taskManagement/taskManagementAction!exportFgxhCg.action",
						data:{"task.bankId":$("#bankId").combobox("getValue"),taskIds:taskIds,"task.vendorId":$("#vendorId").combobox("getValue")},
						dataType:"json",
						timeout:0,
						global:true,
						success: function(rsp){
							if(rsp["status"] == "0"){
								$.messager.alert("系统消息","采购任务导出成功！","info",function(){
									$grid.datagrid("reload");
								});
							}else{
								$.messager.alert("系统消息",rsp["errMsg"],"error");
							}
						},
						complete:function(xhq,textStatus){
							$.messager.progress("close");
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请至少勾选一条任务记录进行导出！","error");
		}
	}
    function initCal(){
        totTaskNums = 0;
        totNums = 0;
    }
    function calRow(is,data){
        if(is){
            totTaskNums = totTaskNums + 1;
            totNums = parseFloat(totNums) + parseFloat(data.TASK_SUM);
        }else{
            totTaskNums = totTaskNums - 1;
            totNums = parseFloat(totNums) - parseFloat(data.TASK_SUM);
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {
                "TASK_ID": "总计：" + totTaskNums + "个任务",
                "TASK_SUM": "总计：" + totNums
            }
        ]);
    }
</script>
<n:initpage title="非个性化卡采购进行管理！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput easyui-validatebox" maxlength="15" data-options="missingMessage:'批次号',invalidMessage:'批次号',required:true,validType:'email'"/></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput easyui-validatebox" maxlength="15" data-options="missingMessage:'任务编号',invalidMessage:'任务编号',required:true,validType:'email'"/></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="task.cardType" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">区域：</td>
						<td class="tableright"><input id="regionId" name="task.regionId" type="text" class="textinput"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td colspan="4" style="text-align:center;">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="notOnlyCardTaskView">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo"  plain="false" onclick="viewNotOnlyTask();">预览</a>
						    </shiro:hasPermission>
						    <shiro:hasPermission name="notOnlyCardTaskAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addNotOnlyTask();">新增</a>
						    </shiro:hasPermission>
						    <shiro:hasPermission name="notOnlyCardTaskDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delNotOnlyTask();">删除</a>
						    </shiro:hasPermission>
						</td>
					</tr>
					<tr>
						<th class="tableleft">银行名称：</th>
						<td class="tableright"><input id="bankId" name="task.bankId" type="text" class="textinput easyui-validatebox" /></td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="非个性化卡制卡任务信息"></table>
	</n:center>
  	<div id="test" data-options="region:'south',split:false,border:true" style="height:70px; width:auto;text-align:center;border-top:none;" class="datagrid-toolbar">
		<h3 class="subtitle">任务导出</h3>
		<table class="datagrid-toolbar" style="width:100%">
			<tr>
			 	<td class="tablecenter" colspan="2">
				    <shiro:hasPermission name="notOnlyCardTaskExp">
				    	卡厂：<input id="vendorId" name="task.vendorId" type="text" class="easyui-combobox"  style="width:200px;"/>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="expNotOnlyTask();">导出</a>
				    </shiro:hasPermission>
				</td>
			</tr>
		</table>
    </div>
</n:initpage>