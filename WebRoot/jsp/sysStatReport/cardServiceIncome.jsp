<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
$(function(){
	$("#synGroupIdTip").tooltip({
		position:"left",    
		content:"<span style='color:#B94A48'>是否级联下级网点</span>" 
	});
	
	$("#cascadeBrch").switchbutton({
		width:"50px",
		value:"0",
        checked:false,
        onText:"是",
        offText:"否"
	});
	
	createRegionSelect({id:"regionId"});
	
	createSysBranch({id:"brchId"});
	
	createSysCode({
		id:"cardType",
		codeType:"CARD_TYPE",
		codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST %>",
		isShowDefaultOption:true
	});
	
	createDataGrid({
		id:"dg",
		url:"sysReportQuery/sysReportQueryAction!cardServiceIncome.action",
		pagination:true,
		rownumbers:true,
		border:false,
		striped:true,
		fit:true,
		fitColumns:true,
		singleSelect:false,
		pageList : [100, 200, 500, 1000, 2000],
		scrollbarSize:0,
		autoRowHeight:true,
		toolbar:"#tb",
		frozenColumns:[[
			{field:"DEAL_NO1",title:"id",sortable:true,checkbox:"ture"},
			{field:"DEAL_NO",title:"流水号",sortable:true},
			{field:"DEAL_CODE_NAME",title:"业务名称",sortable:true},
			{field:"CUSTOMER_ID",title:"客户编号",sortable:true},
			{field:"CUSTOMER_NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.06)},
			{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.05)},
			{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.12)},
			{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.06)}
		]],
		columns:[[
			{field:"CARD_NO",title:"卡号",sortable:true,width:"155px"},
			{field:"COST_FEE",title:"服务费",sortable:true, formatter:function(value, row, index){
				return $.foramtMoney(Number(value).div100());
			}},
			{field:"BIZ_TIME",title:"办理时间",sortable:true},
			{field:"FULL_NAME",title:"办理网点",sortable:true},
			{field:"NAME",title:"柜员",sortable:true},
			{field:"CO_ORG_ID",title:"合作机构编号", hidden:true, sortable:true},
			{field:"CO_ORG_NAME",title:"合作机构名称", hidden:true, sortable:true},
			{field:"TERM_ID",title:"终端编号", hidden:true, sortable:true},
			{field:"END_DEAL_NO",title:"终端流水", hidden:true, sortable:true},
			{field:"CLR_DATE",title:"清分日期",sortable:true},
			{field:"DEAL_STATE",title:"状态",sortable:true},
			{field:"NOTE",title:"备注",sortable:true}
		]],
		onBeforeLoad:function(params){
			if(!params.query){
				return false;
			}
		},
		onSelect:updateFooter,
		onUnselect:updateFooter,
		onSelectAll:updateFooter,
		onUnselectAll:updateFooter
	});
})

function updateFooter(){
	var num = 0;
	var amt = 0;
	var costNum = 0;
	var selections = $("#dg").datagrid("getSelections");
	if(selections && selections.length > 0){
		for(var i in selections){
			num++;
			var cost = isNaN(selections[i].COST_FEE)?0:Number(selections[i].COST_FEE);
			amt += cost;
			if(cost>0){
				costNum++;
			}
		}
	}
	$("#dg").datagrid("reloadFooter", [{
		DEAL_NO:"统计",
		CARD_NO:"共 " + num + " 笔，其中收费 " + costNum + " 笔",
		COST_FEE:amt
	}]);
}

function query(){
		var params = getformdata("searchConts");
		params["query"] = true;
		params["cascadeBrch"] = $("#cascadeBrch").prop("checked");
		$("#dg").datagrid("load", params);
	}
</script>
<n:initpage title="卡服务收入明细进行查询">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright">
							<input id="brchId" name="rec.brchId" type="text" class="textinput"/>
							<span id="synGroupIdTip">
								<input id="cascadeBrch" name="cascadeBrch" type="checkbox">
							</span>
						</td>
						<td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="region_Id" type="text" class="textinput"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="rec.cardType" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="startDate" name="startDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endDate" name="endDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableright" colspan="2" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<!-- <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportFile()">导出</a> -->
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="卡服务收入明细" style="width:100%"></table>
	</n:center>
</n:initpage>