<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	$(function(){
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"120,100",
			value:"120",
			isShowDefaultOption:false
		});
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		
		createSysBranch("recvBrchId");
		
		$("#applyState").combobox({
			textField:"text",
			valueField:"value",
			data:[
				{text:"请选择", value:""},
				{text:"正常", value:"00"},
				{text:"撤销", value:"01"},
				{text:"已申领", value:"02"},
				{text:"已拒绝", value:"03"}
			],
			panelHeight:"auto"
		});
		
		$("#dg").datagrid({
			url:"cardApplysbAction/cardApplysbAction!sbApplyQuery.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageList:[100, 200, 500, 1000, 2000],
			singleSelect:false,
			autoRowHeight:true,
			fitColumns:true,
			toolbar:"#tb",
			columns:[[
			    {field:"", checkbox:true},
				{field:"EMP_ID",title:"单位编号", sortable:true, align:'center',width:parseInt($(this).width() * 0.08)},
				{field:"EMP_NAME",title:"单位名称", sortable:true, align:'center',width:parseInt($(this).width() * 0.15)},
				{field:"NAME",title:"姓名", sortable:true, align:'center',width:parseInt($(this).width() * 0.08)},
				{field:"CERT_NO",title:"证件号码", sortable:true, align:'center',width:parseInt($(this).width() * 0.15)},
				{field:"APPLY_DATE",title:"申报日期", sortable:true, align:'center',width:parseInt($(this).width() * 0.15)},
				{field:"RECV_BRCH_NAME",title:"领卡网点", sortable:true, align:'center',width:parseInt($(this).width() * 0.15)},
				{field:"SB_APPLY_STATE",title:"申报状态", sortable:true, align:'center',width:parseInt($(this).width() * 0.08), formatter:function(v){
					if(v == "00"){
						return "正常";
					} else if (v == "01"){
						return "撤销";
					} else if (v == "02"){
						return "已申领";
					} else if (v == "03"){
						return "已拒绝";
					} else {
						return v;
					}
				}},
				{field:"APPLY_PICI",title:"申报批次", hidden:true, sortable:true, align:'center',width:parseInt($(this).width() * 0.08)},
				{field:"SB_APPLY_ID",title:"申报编号", sortable:true, align:'center',width:parseInt($(this).width() * 0.08)},
				{field:"APPLY_NAME",title:"申报人", hidden:true, sortable:true, align:'center',width:parseInt($(this).width() * 0.08)},
				{field:"COMPANYID",title:"社保单位编号", sortable:true, align:'center',width:parseInt($(this).width() * 0.08)}
			]],
			onLoadSuccess:function(data){
        	    if(data.status != 0){
        		    $.messager.alert("系统消息",data.errMsg,"error");
        		    return;
        	    }
        	},
        	onBeforeLoad:function(params){
        		if(!params || !params.query){
        			return false;
        		}
        		return true;
        	}
		});
	});
	
	function query(){
		var params = {
				query : true,
				corpId : $("#corpId").val(),
				corpName : $("#corpName").val(),
				name : $("#name").val(),
				certNo : $("#certNo").val(),
				startDate : $("#startDate").val(),
				endDate : $("#endDate").val(),
				applyState : $("#applyState").combobox("getValue"),
				recvBrchId : $("#recvBrchId").combotree("getValue")
		};
		$("#dg").datagrid("load", params);
	}
	
	function apply(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length == 0){
			jAlert("请选择需要申领的记录", "warning");
			return;
		}
		
		var sbApplyIds = "";
		for(var i in selections){
			if(selections[i].SB_APPLY_STATE != "00"){
				jAlert("人员【姓名:" + selections[i].NAME + ", 证件号码：" + selections[i].CERT_NO + "】申报状态不是【正常】状态，不能申领", "warning");
				return;
			}
			sbApplyIds += selections[i].SB_APPLY_ID + ","
		}
		
		var cardType = $("#cardType").combobox("getValue");
		
		$.messager.confirm("系统消息", "确认为选中人员申领【<span style='color:red'>" + $("#cardType").combobox("getText") + "</span>】?", function(r){
			if(r){
				$.messager.progress({text:"数据处理中，请稍候...."});
				$.post("cardApplysbAction/cardApplysbAction!doSbApply.action", {applyIds : sbApplyIds.substring(0, sbApplyIds.length - 1), cardType:cardType}, function(data){
					$.messager.progress("close");
					if(data.status == 1){
						jAlert(data.errMsg);
					} else {
						jAlert("申领成功", "info", function(){
							$("#dg").datagrid("reload");
						});
					}
				}, "json");
			}
		});
	}
</script>
<n:initpage title="社保申领数据处理：注意：只申领社保同步状态正常的人员信息！">
	<n:center>
		<div id="tb">
			<table class="tablegrid">
					<tr>
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" class="textinput"></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpName" class="textinput"></td>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input id="name" class="textinput"></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo" class="textinput"></td>
					</tr>
					<tr>
						<td class="tableleft">申报起始时间：</td>
						<td class="tableright"><input id="startDate" name="startDate" type="text" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'#F{$dp.$D(\'endDate\')}'})"/></td>
						<td class="tableleft">申报结束时间：</td>
						<td class="tableright"><input id="endDate" name="endDate" type="text" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">申报状态：</td>
						<td class="tableright"><input id="applyState" class="textinput"></td>
						<td class="tableleft">领卡网点：</td>
						<td class="tableright"><input id="recvBrchId" class="textinput"></td>
					</tr>
					<tr>
						<td style="padding-right:5%" colspan="8" class="tableleft">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>&nbsp;
							<shiro:hasPermission name="doSbApply">
								<input id="cardType" class="textinput">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="apply()">申领</a>
							</shiro:hasPermission>
						</td>
					</tr>
			</table>
		</div>
  		<table id="dg" title="社保申报申领信息"></table>
	</n:center>
</n:initpage>