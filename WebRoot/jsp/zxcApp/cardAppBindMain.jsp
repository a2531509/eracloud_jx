<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@include file="/layout/initpage.jsp" %>
<script>
	var $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				toQuery();
			}
		});
		
		createSysOrg(
			{id:"orgId"},
			{id:"brchId"},
			{id:"userId"}
		);
		createLocalDataSelect({
			id:"appType",
			data:[
				{value:"",text:"请选择"},
			    {value:"01",text:"广电"},
			    {value:"02",text:"自来水"},
			    {value:"03",text:"电力"},
			    {value:"04",text:"过路过桥"},
			    {value:"05",text:"自行车"},
			    {value:"06",text:"移动"}
			]
		});
		createLocalDataSelect({
			id:"bindState",
			data:[
				{value:"",text:"请选择"},
			    {value:"0",text:"正常"},
			    {value:"1",text:"注销"},
			]
		});
		$grid = createDataGrid({
			id:"dg",
			url:"zxcApp/ZxcAppAction!queryAllAppBind.action",
			border:false,
			fit:true,
			scrollbarSize:0,
			fitColumns:true,
			pageList:[50,80,100,150,200,300,500],
			columns:[[
				{field:"DEAL_NO",title:"id",sortable:true,checkbox:true},
				{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"SEX",title:"性别",sortable:true},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"BINDTYPE",title:"应用类型",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"BINDDATE",title:"开通日期",sortable:true,width : parseInt($(this).width() * 0.1)},
				{field:"BINDSTATE",title:"状态",sortable:true,width : parseInt($(this).width() * 0.05)},
				{field:"FULL_NAME",title:"网点",sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:"OPERNAME",title:"柜员",sortable:true,width : parseInt($(this).width() * 0.08)}
			]]
		});
		//$.addNumber("merchantId");
		$.addNumber("cardNo");
		$.addNumber("dealNo");
		$.autoComplete({
			id:"merchantId",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			where:"corp_state = '0'",
			keyColumn:"customer_id,corp_name",
			minLength:1,
			reverse:true
		});
	});
	function toQuery(){
		var options = getformdata("appBindForm");
		options["queryType"] = "0";
		$grid.datagrid("load",options);
	}
</script>
<n:initpage title="卡开通的应用进行查询操作！">
	<n:center>
		<div id="tb">
			<form id="appBindForm">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">所属机构：</td>
						<td class="tableright"><input name="orgId" type="text" class="textinput" id="orgId"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input name="cardAppBind.brchId" type="text" class="textinput" id="brchId"/></td>
						<td class="tableleft">所属柜员：</td>
						<td class="tableright"><input name="cardAppBind.userId" type="text" class="textinput" id="userId"/></td>
						<td class="tableleft">应用类型：</td>
						<td class="tableright"><input name="cardAppBind.appType" type="text" class="textinput" id="appType" /></td>
					</tr>
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input name="cardAppBind.merchantId" id="merchantId" class="textinput"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardAppBind.cardNo" id="cardNo" class="textinput"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="personal.certNo" id="certNo" class="textinput"/></td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input name="cardAppBind.bindState" id="bindState" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">绑定流水：</td>
						<td class="tableright"><input name="cardAppBind.dealNo" id="dealNo" class="textinput"/></td>
						<td class="tableleft">开始日期：</td>
						<td class="tableright"><input id="startDate" name="startDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endDate" name="endDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td colspan="2" style="text-align:center;"><a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQuery()">查询</a></td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="应用开通与绑定信息"></table>
	</n:center>
</n:initpage>