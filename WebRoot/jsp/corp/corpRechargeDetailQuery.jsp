<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	var totNum = 0;
	var totAmt = 0;
	$(function(){
		if(dealNull("${defaultErrorMsg}") != ""){
			jAlert("${defaultErrorMsg}");
		}
		$.autoComplete({
			id:"customerId",
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
		},"customerId");
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!corpRechargeDetails.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageSize:50,
			singleSelect:false,
			autoRowHeight:true,
			fitColumns:true,
			scrollbarSize:0,
			pageList:[50,100,200,300,500,800,1000,2000],
			columns:[[
				{field:"ACC_INOUT_NO",title:"流水编号",sortable:true,checkbox:true},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CARD_NO",title:"市民卡卡号",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"ACCNAME",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"AMT",title:"充值金额",sortable:true,width:parseInt($(this).width() * 0.1),formatter:function(value,row,index){
					var ss = dealNull(value).split(":");
					var finalstr = "";
					if(ss.length > 1){
						finalstr += (dealNull(ss[1]) == "" ? "" : (ss[1] + "："));
					}
					return finalstr + $.foramtMoney(Number(ss[0]).div100());
				}},
				{field:"DEALDATE",title:"充值日期",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CORP_NAME",title:"充值单位",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"FULL_NAME",title:"办理网点",sortable:true},
				{field:"USERNAME",title:"办理柜员",sortable:true}
			]],
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
            },
			onLoadSuccess:function(data){
				initGridFooter();
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
				}
				updateFooter();
			}
		});
	});
	function initGridFooter(){
		totNum = 0;
		totAmt = 0;
	}
	function initCal(){
		totNum = 0;
		totAmt = 0;
	}
	function calRow(is,data){
		if(is){
			totNum = parseFloat(totNum) + 1;
			totAmt = parseFloat(totAmt) + (isNaN(data.AMT) ? 0 : parseFloat(data.AMT));
		}else{
			totNum = parseFloat(totNum) - 1;
			totAmt = parseFloat(totAmt) - (isNaN(data.AMT) ? 0 : parseFloat(data.AMT));
		}
	}
	function updateFooter(){
		$grid.datagrid('reloadFooter',[
   	        {	
   	        	CERT_NO:"本页信息统计：",
   	        	ACCNAME:"总笔数：" + totNum,
   	        	AMT:totAmt + ":总金额"
   	        }
   	    ]);
	}
	function query(){
		if(dealNull($("#beginTime").val()) == ""){
			jAlert("请输入查询起始日期！",function(){
				$("#startDate").focus();
			});
			return;
		}
		if(dealNull($("#endTime").val()) == ""){
			jAlert("请输入查询结束日期！",function(){
				$("#endDate").focus();
			});
			return;
		}
		if($("#beginTime").val() > $("#endTime").val()){
			jAlert("起始日期不能大于结束日期！");
			return;
		}
		var params = getformdata("cardreFormList");
		params["beginTime"] = $("#beginTime").val();
		params["endTime"] = $("#endTime").val();
		params["queryType"] = "0";
		params["baseCorp.corpName"] = $("#corpName").val();
		$grid.datagrid("load",params);
	}
</script>
<n:initpage title="单位充值情况进行查询操作！">
	<n:center>
		<div id="tb">
			<form id="cardreFormList">
				<input id="sort" name="sort" type="hidden">
				<input id="order" name="order" type="hidden">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo"  name="rec.certNo" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input  id="cardNo" type="text" name="rec.cardNo" class="textinput" maxlength="20"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="customerId"  name="baseCorp.customerId" type="text" class="textinput" maxlength="20"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpName"  name="baseCorp.corpName" type="text" class="textinput" maxlength="20"/></td>
						<td colspan="2">
							&nbsp;
						</td>
						<td colspan="2" style="text-align:center;"><a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a></td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="车改充值明细"></table>
	</n:center>
</n:initpage>