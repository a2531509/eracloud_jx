<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function() {
		$.autoComplete({
			id:"merchantId",
			text:"merchant_id",
			value:"merchant_name",
			table:"base_merchant",
			keyColumn:"merchant_id",
			minLength:"1"
		},"merchantName");
		
		$.autoComplete({
			id:"merchantName",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			keyColumn:"merchant_name",
			minLength:"1"
		},"merchantId");
		$("#dg").datagrid({
			url:"merchantSettle/merchantSettleAction!merSettlePayInfo.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageSize:20,
			singleSelect:false,
			autoRowHeight:true,
			fitColumns:true,
			toolbar:"#tb",
			columns:[[
				{field:"", checkbox:true, rowspan:2},
				{field:"MERCHANT_ID",title:"商户编号",sortable:true, rowspan:2, width:100},
				{field:"MERCHANT_NAME",title:"商户名称",sortable:true, rowspan:2, width:200},
				{title:"已结算",colspan:2},
				{title:"已支付",colspan:2},
				{title:"未支付",colspan:2},
				{field:"LAST_PAY_TIME",title:"最后支付时间", align:"center",sortable:true, rowspan:2, width:100}
			], [
			    {field:"YJS_NUM",title:"笔数", align:"center",sortable:true, rowpan:2, width:50},
			    {field:"YJS_AMT",title:"金额", align:"center",sortable:true, rowpan:2, width:50, formatter:function(v){
			    	if(isNaN(v)){
			    		v = 0;
			    	}
			    	return $.foramtMoney(Number(v).div100());
			    }},
			    {field:"YZF_NUM",title:"笔数", align:"center",sortable:true, rowpan:2, width:50},
			    {field:"YZF_AMT",title:"金额", align:"center",sortable:true, rowpan:2, width:50, formatter:function(v){
			    	if(isNaN(v)){
			    		v = 0;
			    	}
			    	return $.foramtMoney(Number(v).div100());
			    }},
			    {field:"WZF_NUM",title:"笔数", align:"center",sortable:true, rowpan:2, width:50},
			    {field:"WZF_AMT",title:"金额", align:"center",sortable:true, rowpan:2, width:50, formatter:function(v){
			    	if(isNaN(v)){
			    		v = 0;
			    	}
			    	return $.foramtMoney(Number(v).div100());
			    }}
			]],
			onBeforeLoad:function(params){
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
	})
	
	function query() {
		var params = getformdata("searchConts");
		$("#dg").datagrid("load", params);
	}
</script>
<n:initpage title="商户结算支付情况进行查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input  id="merchantId" type="text" class="textinput" name="merchantId" /></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input id="merchantName" type="text" name="merchantName" class="textinput"/></td>
						<td class="tableleft">结算起始时间:</td>
						<td class="tableright"><input id="startDate" name="startDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"></td>
						<td class="tableleft">结算结束时间:</td>
						<td class="tableright">
							<input id="endDate" name="endDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d', minDate:'#F{$dp.$D(\'startDate\')}'})">
							&nbsp;<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="商户结算支付情况"></table>
  	</n:center>
</n:initpage>