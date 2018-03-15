<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var  $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		//$.addNumber("applyId");
        $.autoComplete({
            id:"taskId",
            text:"task_id",
            value:"task_name",
            table:"card_apply_task",
            keyColumn:"task_id",
            optimize:true,
            minLength:"1"
        },"companyName");
        $.autoComplete({
            id:"companyName",
            text:"task_name",
            value:"task_id",
            table:"card_apply_task",
            keyColumn:"task_name",
            optimize:true,
            minLength:"1"
        },"taskId");
		$.addNumber("buyPlanId");
		$.addNumber("taskId");
		$.addIdCardReg("certNo");
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:"1"
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:"1"
		},"corpId");
		createSysCode({
			id:"applyWay",
			codeType:"APPLY_WAY"
		});
		createSysBranch(
			{id:"branchId", isJudgePermission:false},
			{id:"operId"}
		);
 		createRegionSelect(
 			{id:"regionId"},
 			{id:"townId"},
 			{id:"commId"}
 		);
 		$grid = createDataGrid({
			id:"applyMsgs",
			url:"cardapply/cardApplyAction!yhFailPersonInfo.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			singleSelect:true,
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:false,
			pageSize:20,
			frozenColumns:[[
				{field:"", checkbox:true},
				{field:"APPLY_ID",title:"申领编号",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"BUY_PLAN_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"MOBILE_NO",title:"手机号码",sortable:true,width:parseInt($(this).width() * 0.1)}
			]],
			columns:[[
				{field:"CORP_NAME",title:"所属单位",sortable:true},
				{field:"APPLYWAY",title:"申领方式",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"BRCH_NAME",title:"申领网点",sortable:true},
				{field:"USER_NAME",title:"申领柜员",sortable:true},
				{field:"APPLYDATE",title:"申领时间",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13)},
                {field:"BANK_ID",title:"银行编号",sortable:true},
                {field:"BANK_NAME",title:"银行名称",sortable:true},
				{field:"BANK_CHECKREFUSE_REASON",title:"银行审核失败原因",sortable:true}
			]],
			onBeforeLoad:function(params){
				if(!params["queryType"]){
					return false;
				}
			}
		});
	});
	function query(){
		var params = getformdata("applyMsgForm");
		params["queryType"] = true;
		params["bp.name"] = $("#name").val();
		$grid.datagrid("load",params);
	}
	function readIdCard(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#certNo").val(certinfo["cert_No"]);
		}
	}
	function applyCancel(){
		 var rows = $grid.datagrid("getChecked");
		 if(rows.length == 1){
			if(rows[0].APPLY_STATE != "<%=com.erp.util.Constants.APPLY_STATE_YSQ%>"){
				$.messager.alert("系统消息","勾选的申领记录状态不是【已申请】，无法进行删除！","error");
				return;
			}
			if(rows[0].APPLY_WAY != "<%=com.erp.util.Constants.APPLY_WAY_LX%>"){
				$.messager.alert("系统消息","勾选的申领记录的申领类型不是【零星申领】，无法进行删除！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要撤销选定的申领吗？", function(r){
	     		if (r){
	    			$.messager.progress({text:"数据处理中，请稍后...."});
  					$.post("cardapply/cardApplyAction!saveUndoCardApply.action", {apply_Id:rows[0].APPLY_ID},function(data,status){
						$.messager.progress("close");
				     	if(data.status == "0"){
				     		$.messager.alert("系统消息","申领撤销保存成功","info",function(){
				     			showReport("申领撤销",data.dealNo,function(){
				     				$grid.datagrid("reload");
				     			});
					     		
				     		});
				     	}else{
				     		$.messager.alert("系统消息",data.msg,"error");
				     	}
					},"json");
	     		}
	     	});
		}else{
			$.messager.alert("系统消息","请选择一条记录进行操作！","error");
			return;
		}
	}
	function exportDetail() {
		var selectId = "";
		var selections = $("#applyMsgs").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				selectId += "|" + selections[i].APPLY_ID;
			}
		}
		
		var params = getformdata("applyMsgForm");
		params["rows"] = 65530;
		params["bp.name"] = $("#name").val();
		if(selectId){
			params["selectedId"] = selectId.substring(1);
		}
		
		var paramsStr = "";
		for(var i in params){
			paramsStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"正在进行导出,请稍候..."});
		$('#download_iframe').attr('src',"cardapply/cardApplyAction!exportYhFailPersonInfo.action?" + paramsStr.substring(1));
		startCycle();
	}
	
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportYhFailPersonInfo",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
</script>
<n:initpage title="银行审核不通过的记录进行查看！">
	<n:center>
	  	<div id="tb">
	  		<form id="applyMsgForm" >
				<table class="tablegrid">
					<tr>
						<td  class="tableleft" style="width:8%">任务编号：</td>
						<td  class="tableright" style="width:17%"><input name="apply.taskId"  class="textinput" id="taskId" type="text" maxlength="20"/></td>
						<td  class="tableleft" style="width:8%">任务名称：</td>
						<td  class="tableright" style="width:17%"><input name="companyName"  class="textinput" id="companyName" type="text" maxlength="50"/></td>
						<td  class="tableleft" style="width:8%">证件号码：</td>
						<td  class="tableright" style="width:17%"><input name="bp.certNo"  class="textinput" id="certNo" type="text" maxlength="18" /></td>
						<td  class="tableleft" style="width:8%">客户姓名：</td>
						<td  class="tableright" style="width:17%"><input name="bp.name"  class="textinput" id="name" type="text" maxlength="30"/></td>
					</tr>
					<tr>
						<td class="tableleft" style="width:8%">办理网点：</td>
						<td class="tableright" style="width:17%"><input name="apply.applyBrchId"  class="textinput" id="branchId" type="text"/></td>
						<td class="tableleft" style="width:8%">办理柜员：</td>
						<td class="tableright" style="width:17%"><input name="apply.applyUserId"  class="textinput" id="operId" type="text"/></td>
						<td class="tableleft" style="width:8%">申领起始时间：</td>
						<td class="tableright" style="width:17%"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft" style="width:8%">申领截至时间：</td>
						<td class="tableright" style="width:17%"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft" style="width:8%">单位编号：</td>
						<td  class="tableright" style="width:17%"><input name="apply.corpId"  class="textinput" id="corpId" type="text" maxlength="20"/></td>
						<td  class="tableleft" style="width:8%">单位名称：</td>
						<td  class="tableright" style="width:17%"><input name="corpName"  class="textinput" id="corpName" type="text" maxlength="30"/></td>
                        <td  class="tableleft" style="width:8%">批次号：</td>
                        <td  class="tableright" style="width:17%"><input name="apply.buyPlanId"  class="textinput" id="buyPlanId" type="text" maxlength="20"/></td>
					    <td  colspan="2" style="padding-left: 20px" class="tableright">
					    	<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="query()">查询</a>
					    	<a data-options="plain:false,iconCls:'icon-export'" href="javascript:void(0)" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
					    </td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="applyMsgs" title="银行审核不通过信息"></table>
  		<iframe id="download_iframe" style="display: none;"></iframe>
	</n:center>
</n:initpage>