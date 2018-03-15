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
			{id:"branchId",isJudgePermission:false},
			{id:"operId"}
		);
 		createRegionSelect(
 			{id:"regionId"},
 			{id:"townId"},
 			{id:"commId"}
 		);
 		$grid = createDataGrid({
			id:"applyMsgs",
			url:"cardapply/cardApplyAction!toSearchApplyMsg.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			singleSelect:true,
			pageList:[10,20,30,40,50,100,200,500],
			singleSelect:false,
			pageSize:20,
			checkbox:true,
			frozenColumns:[[
			    {field:"SELECTID",checkbox:true},
				{field:"APPLY_ID",title:"申领编号",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"MAKE_BATCH_ID",title:"批次号",sortable:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width() * 0.03)},
			]],
			columns:[[
				{field:"APPLYWAY",title:"申领方式",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"FULL_NAME",title:"申领网点",sortable:true},
				{field:"USERNAME",title:"申领柜员",sortable:true},
				{field:"APPLYDATE",title:"申领时间",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13)},
				{field:"APPLYSTATE",title:"申领状态",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"IS_JUDGE_SB_STATE",title:"是否判断社保",sortable:true, formatter:function(v){
					if(v == 1){
						return "否";
					} else {
						return "是";
					}
				}},
                {field:"BANK_ID",title:"银行编号",sortable:true},
                {field:"BANK_NAME",title:"银行名称",sortable:true},
				{field:"BANK_CHECKREFUSE_REASON",title:"审核结果",sortable:true},
				{field:"AGTCERTTYPE",title:"申领代理人证件类型",sortable:true},
				{field:"AGT_CERT_NO",title:"申领代理人证件号码",sortable:true},
				{field:"AGT_NAME",title:"申领代理人姓名",sortable:true},
				{field:"AGT_PHONE",title:"申领代理人联系电话",sortable:true},
				{field:"RECV_CERT_TYPE",title:"领卡代理人证件类型",sortable:true},
				{field:"RECV_CERT_NO",title:"领卡代理人证件号码",sortable:true},
				{field:"RECV_NAME",title:"领卡代理人姓名",sortable:true},
				{field:"RECV_PHONE",title:"领卡代理人联系电话",sortable:true},
				{field:"RELS_BRCH_ID",title:"发放网点",sortable:true},
				{field:"RELS_USER_ID",title:"发放柜员",sortable:true},
				{field:"RELS_DATE",title:"发放时间",sortable:true},
				{field:"REGION_NAME",title:"所属区域",sortable:true},
				{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true,formatter:function(value,row,index){
					return "<div style='width:100%;height:100%;' title='" + value + "'>" + value + "</span>";
				}},
				{field:"COMM_NAME",title:"社区（村）",sortable:true,formatter:function(value,row,index){
					return "<div style='width:100%;height:100%;' title='" + value + "'>" + value + "</span>";
				}},
				{field:"CORP_NAME",title:"单位",sortable:true,formatter:function(value,row,index){
					return "<div style='width:100%;height:100%;' title='" + value + "'>" + value + "</span>";
				}}
			]]
		});
	});
	function query(){
		var params = getformdata("applyMsgForm");
		params["queryType"] = "0";
		params["bp.name"] = $("#name").val();
		params["corpName"] = $("#corpName").val();
		params["companyName"] = $("#companyName").val();
		params["beginTime"] = $("#beginTime").val();
		params["endTime"] = $("#endTime").val();
		params["queryType"] = "0";
		if(params["isNotBlankNum"] < 1){
			$.messager.alert("系统消息","查询参数不能全部为空！请至少输入或选择一个查询参数","warning");
			return;
		}
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
	function exportExcel() {
		var rows = $grid.datagrid("getChecked");
		if(rows.length > 0) {
			var applyIds = "";
			for(var index = 0; index < rows.length; index++) {
				applyIds += "'" + rows[index].APPLY_ID + "'";
				if(index != rows.length - 1) {
					applyIds += ",";
				}
			}
			$.messager.confirm("系统消息","您确定要导出选中的申领数据？",function(r){
				if(r){
					$("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
					$("#downloadcsv").attr("src","cardapply/cardApplyAction!exportCardApply.action?applyIds="+applyIds);
				}
			});
		}else{
			$.messager.alert("系统消息","请选择要导出的申领记录！","error");
			return;
		}
	}
	if("<%=com.erp.util.Constants.ENTER_TO_QUERY%>" == "0"){
		$(document).keypress(function(e){
			if(e.keyCode == 13){
				query();
			}
		});
	}
</script>
<n:initpage title="申领记录进行查询操作！">
	<n:center>
	  	<div id="tb">
	  		<form id="applyMsgForm" >
				<table class="tablegrid">
					<tr id="dwapply">
						<td  class="tableleft" style="width:8%">证件号码：</td>
						<td  class="tableright" style="width:17%"><input name="bp.certNo"  class="textinput" id="certNo" type="text" maxlength="18" /></td>
						<td  class="tableleft" style="width:8%">客户姓名：</td>
						<td  class="tableright" style="width:17%"><input name="bp.name"  class="textinput" id="name" type="text" maxlength="30"/></td>
						<td  class="tableleft" style="width:8%">任务编号：</td>
						<td  class="tableright" style="width:17%"><input name="apply.taskId"  class="textinput" id="taskId" type="text" maxlength="20"/></td>
						<td  class="tableleft" style="width:8%">任务名称：</td>
						<td  class="tableright" style="width:17%"><input name="companyName"  class="textinput" id="companyName" type="text" maxlength="50"/></td>
					</tr>
					<tr>
						<%--<td  class="tableleft" style="width:8%">申领编号：</td>
						<td  class="tableright" style="width:17%"><input name="apply.applyId"  class="textinput" id="applyId" type="text" maxlength="15"/></td>--%>
                        <td  class="tableleft" style="width:8%">批次号：</td>
                        <td  class="tableright" style="width:17%"><input name="apply.buyPlanId"  class="textinput" id="buyPlanId" type="text" maxlength="20"/></td>
						<td  class="tableleft" style="width:8%">申领方式：</td>
						<td  class="tableright" style="width:17%"><input name="apply.applyWay"  class="textinput" id="applyWay" type="text"/></td>
						<td class="tableleft" style="width:8%">办理网点：</td>
						<td class="tableright" style="width:17%"><input name="apply.applyBrchId"  class="textinput" id="branchId" type="text"/></td>
						<td class="tableleft" style="width:8%">办理柜员：</td>
						<td class="tableright" style="width:17%"><input name="apply.applyUserId"  class="textinput" id="operId" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft" style="width:8%">单位编号：</td>
						<td  class="tableright" style="width:17%"><input name="apply.corpId"  class="textinput" id="corpId" type="text" maxlength="20"/></td>
						<td  class="tableleft" style="width:8%">单位名称：</td>
						<td  class="tableright" style="width:17%"><input name="corpName"  class="textinput" id="corpName" type="text" maxlength="30"/></td>
						<td class="tableleft" style="width:8%">申领起始时间：</td>
						<td class="tableright" style="width:17%"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft" style="width:8%">申领截至时间：</td>
						<td class="tableright" style="width:17%"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
					 	<td  class="tableleft" style="width:8%">所属区域：</td>
						<td  class="tableright" style="width:17%"><input name="bp.regionId"  class="textinput"  id="regionId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft" style="width:8%">乡镇（街道）：</td>
						<td  class="tableright" style="width:17%"><input name="bp.townId"  class="textinput" id="townId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft" style="width:8%">社区（村）：</td>
						<td  class="tableright" style="width:17%"><input name="bp.commId"  class="textinput easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
					    <td  colspan="2" style="text-align:center; width: 25%">
					    	<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
					    	<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="query()">查询</a>
					    	<a data-options="plain:false,iconCls:'icon-back'" href="javascript:void(0);" class="easyui-linkbutton" onclick="applyCancel()">申领撤销</a>
					    	<a data-options="plain:false,iconCls:'icon-back'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportExcel()">导出</a>
					    </td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="applyMsgs" title="查询条件"></table>
	</n:center>
</n:initpage>