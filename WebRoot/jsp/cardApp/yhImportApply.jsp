<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function() {
		createCustomSelect({
			id:"bankIdimp",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank", 
			where:"bank_state = '0'",
			orderby:"bank_id asc"
		});
		createSysCode({
			id:"taskState",
			codeType:"TASK_STATE",
			isShowDefaultOption:false,
			codeValue:"<%=com.erp.util.Constants.TASK_STATE_YFYH %>"
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
		$grid = createDataGrid({
			id:"dg",
			url:"taskManagement/taskManagementAction!cardTaskQuery.action",
			border:false,
			fit:true,
			fitColumns: true,
			scrollbarSize:0,
			columns:[[
                {field:"SETTLEID",title:"id",sortable:true,checkbox:"ture"},
				{field:"TASK_ID",title:"任务编号",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"TASKSTATE",title:"任务状态",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"TASKWAY",title:"任务组织方式",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"TASK_NAME",title:"任务名称",sortable:true,width : parseInt($(this).width() * 0.2)},
				{field:"TASK_DATE",title:"任务时间",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"TASK_SUM",title:"任务数量",sortable:true,width : parseInt($(this).width() * 0.05)}
            ]]
		});
		var pager = $grid.datagrid("getPager");
        pager.pagination({
            buttons:$("#zhuguanPwdDiv")
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
        $.addNumber("makeBatchId");
        $.addNumber("taskId");
        $.addNumber("corpId");
	});
	function query(){
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		params["corpName"] = $("#corpName").val();
		$grid.datagrid("load",params);
	}
	function importBank(){
		var bankId = $("#bankIdimp").combobox("getValue");
		if(dealNull(bankId) == ""){
			$.messager.alert("系统消息","请选择银行数据信息！","error",function(){
				$("#bankIdimp").combobox("showPanel");
			});
			return false;
		}
		$.messager.confirm("系统消息","您确定要导入【" + $("#bankIdimp").combobox("getText") + "】的审核结果数据吗？" ,function(r){
			if(r){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.ajax({
					url:"taskManagement/taskManagementAction!saveImportTaskRhFile.action",
					data:{"task.bankId":$("#bankIdimp").combobox("getValue")},
					dataType:"json",
					success: function(rsp){
						$.messager.progress("close");
						if(rsp.status == "0"){
							$.messager.alert("系统消息",rsp.msg,"info");
							$("#bankIdimp").combobox("setValue","");
						}else{
							$.messager.alert("系统消息",rsp.msg,"error");
						}
					}
				});
			}
		});
	}
</script>
<n:initpage title="已发银行的制卡任务进行查询并导入银行审核返回文件操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="makeBatchId" name="task.makeBatchId" type="text" class="textinput" /></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="taskId" name="task.taskId" type="text" class="textinput" /></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="task.taskState" type="text" class="textinput"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="task.cardType" type="text"  class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="task.corpId" class="textinput" type="text" maxlength="20"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpName" name="corpName" class="textinput" type="text" maxlength="60"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="task.regionId"  type="text" class="textinput"/></td>
						<td class="tableleft">乡镇（街道）：</td>
						<td class="tableright"><input id="townId" name="task.townId" type="text" class="textinput"/></td>
						<td class="tableleft">社区（村）：</td>
						<td class="tableright"><input id="commId" name="task.commId" type="text" class="textinput"/></td>
						<td style="text-align:center" colspan="2">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="任务信息"></table>
  		<div id="zhuguanPwdDiv">
            <table>
	            <tr> 
					<shiro:hasPermission name="cardOnlyTaskImpByBank">
					    <td width="150px" align="right">导入银行编号：</td>
		 				<td>
		 					<input id="bankIdimp" name="bankIdimp" type="text" class="easyui-combobox"  style="width:124px;"/>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import"  plain="false" onclick="importBank();">导入银行返回</a>
					    </td>
	  				</shiro:hasPermission>
	            </tr>	
            </table>
        </div>
  	</n:center>
</n:initpage>