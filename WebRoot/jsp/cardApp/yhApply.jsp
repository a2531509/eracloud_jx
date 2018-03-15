<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		createCustomSelect({
			id:"taskOperId",
			value:"user_id",
			text:"name||'【'||user_id||'】'",
			table:"sys_users",
			where:"status = 'A'",
			orderby:"user_id asc",
			from:1,
			to:5000,
			editable:true
		});
		$("#isBatchHf").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"是"},
				{value:"1", text:"否"}
			],
			editable:false
		});
		createCustomSelect({
			id:"queryBankId",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:200,
            onSelect:function(r){
                $("#brchId").combotree('clear');
                $("#brchId").combotree("reload","commAction!findAllRecvBranch.action?bankId=" + r.VALUE);
            }
		});
        $("#synGroupIdTip").tooltip({
            position:"left",
            content:"<span style='color:#B94A48'>是否判断同一领卡网点</span>"
        });
        $("#isList").switchbutton({
            width:50,
            value:"0",
            checked:false,
            onText:"是",
            offText:"否",
            onChange:function(checked){
            }
        });
        createRecvBranch({
            id:"brchId"
        });
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			isShowDefaultOption:false,
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YSC %>"
		});
		createSysCode({
			id:"taskWay",
			codeType:"TASK_WAY",
			isShowDefaultOption:true
		});
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
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action",
			border:false,
			scrollbarSize:0,
			singleSelect:false,
            pageSize:50,
            pageList:[50,100,300,500,1000],
            showFooter:true,
			frozenColumns:[[
                {field:"SETTLEID",title:"id",sortable:true,checkbox:"ture"},
				{field:"TASK_ID",title:"任务编号",sortable:true},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width : parseInt($(this).width() * 0.2)}
			]],
			columns:[[   
				{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true},
				{field:"IS_URGENT",title:"制卡方式",sortable:true},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width : parseInt($(this).width() * 0.05)},         
				{field:"BRCH_ID",title:"领卡网点编号",sortable:true},
				{field:"LKBRCHNAME",title:"领卡网点名称",sortable:true},
				{field:"BANK_ID",title:"审核银行编号",sortable:true},
				{field:"BANK_NAME",title:"审核银行名称",sortable:true},
				{field:"IS_BATCH_HF",title:"是否换发",sortable:true, formatter:function(v){
					if(v == "0"){
						return "是";
					} else {
						return "否";
					}
				}}
			]],
			onLoadSuccess:function(){
				updateFooter();
			},
			onSelect:updateFooter,
			onUnselect:updateFooter,
			onSelectAll:updateFooter,
			onUnselectAll:updateFooter
		});
        $.addNumber("taskId");
        $.addNumber("corpId");
	});
	function updateFooter(){
		var taskNum = 0;
		var taskSum = 0;
		var selections = $grid.datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				taskNum++;
				taskSum += isNaN(selections[i].TASK_SUM)?0:Number(selections[i].TASK_SUM);
			}
		}
		$grid.datagrid("reloadFooter", [{TASK_ID:"统计：", TASK_NAME:"共 " + taskNum + " 个任务", TASK_SUM:taskSum}]);
	}
	function query(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	function exportBank(){
		var rows = $grid.datagrid("getChecked");
		var taskIds = "";
		if(!rows || rows.length <= 0){
			$.messager.alert("系统消息","请勾选将要进行导出的任务记录信息！","warning");
			return;
		}
		for(var i = 0;i < rows.length;i++){
			if(rows[i].TASK_STATE != <%=com.erp.util.Constants.TASK_STATE_YSC%>){
				$.messager.alert("系统消息","任务名称【" + rows[i].TASK_NAME + "】的任务状态不为【任务已生成】！","warning");
				return;
			}
			if(dealNull(rows[i].BRCH_ID) == ""){
				$.messager.alert("系统消息","任务名称【" + rows[i].TASK_NAME + "】的领卡网点未设置！","warning");
				return;
			}
			if(dealNull(rows[i].BANK_ID) == ""){
				$.messager.alert("系统消息","任务名称【" + rows[i].TASK_NAME + "】的领卡网点未绑定银行！","warning");
				return;
			}
			if(i == rows.length - 1){
				taskIds = taskIds + rows[i].SETTLEID;
			}else{
				taskIds = taskIds + rows[i].SETTLEID + "|";
			}
		}
		$.messager.confirm("系统消息","您确定要将勾选的任务导出给银行进行审核吗？",function(is){
			if(is){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.ajax({
					dataType:"json",
					global:true,
					url:"taskManagement/taskManagementAction!exportFtpFileToBank.action",
				    data:{
				    	"taskIds":taskIds,
                        "task.isList":(document.getElementById("isList").checked ? "0" : "1")
				    },
					success:function(rsp){
						$.messager.progress("close");
						if(dealNull(rsp.status) == "0"){
							$.messager.alert("系统消息",rsp.msg,"info",function(){
								$("#bankId").combobox("setValue","");
								query();
							});
						}else{
							$.messager.alert("系统消息",rsp.msg,"error");
						}
					}
				});
			}
		});
	}
</script>
<n:initpage title="个性化制卡数据导出给银行进行审核操作！<span style='color:red;'>注意：</span>只有任务状态是【任务已生成】才能进行导出！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">单位编号：</td>
						<td  class="tableright"><input name="task.corpId"  class="textinput" id="corpId" type="text" maxlength="30"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpName" name="corpName"  class="textinput"  type="text" maxlength="50"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">乡镇（街道）：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区（村）：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
                        <td class="tableleft">卡类型：</td>
                        <td class="tableright"><input id="cardType" name="task.cardType" type="text"  class="textinput"/></td>
					</tr>
					<tr>
                        <td class="tableleft">领卡网点所属银行：</td>
                        <td class="tableright"><input id="queryBankId" name="task.bankId" type="text" class="textinput"/></td>
                        <td class="tableleft">领卡网点：</td>
                        <td class="tableright"><input id="brchId" name="task.brchId" type="text" class="textinput"/></td>
                        <td class="tableleft">任务组织方式：</td>
                        <td class="tableright"><input id="taskWay" name="task.taskWay" type="text" class="textinput"/></td>
                        <td class="tableleft">任务状态：</td>
                        <td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">任务柜员：</td>
                        <td class="tableright"><input id="taskOperId" name="task.taskOperId" type="text" class="textinput"/></td>
                        <td class="tableleft">是否换发：</td>
                        <td class="tableright"><input id="isBatchHf" name="task.isBatchHf" type="text" class="textinput"/></td>
						<td colspan="4" class="tableleft" style="padding-right: 10px">
                            <span id="synGroupIdTip">
								<input id="isList" name="task.isList" type="checkbox">
							</span>
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="cardOnlyTaskExpToBank">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="exportBank();">导出银行</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
	</n:center>
</n:initpage>