<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	var $grid;
	var totalNum = 0;
	var totalAmt = 0.00;
	$(function() {
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>"
		});
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND"
		});
		createSysBranch(
			{id:"branchId"},
			{id:"userId"}
		);
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!rechargeAndConsumeStatistics.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageList:[100, 500, 1000, 2000, 5000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			frozenColumns:[[
				{field:"DEAL_NO1",title:"id",sortable:true,checkbox:"ture"},
				{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"DEAL_BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"DEAL_CODE",title:"业务名称",sortable:true},
				{field:"ACPT_ID",title:"受理点编号",sortable:true},
				{field:"FULL_NAME",title:"受理点名称",sortable:true}
			]],
			columns:[[
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"ACC_NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.13)},
				{field:"ACC_NO",title:"账户号",sortable:true,width:parseInt($(this).width()*0.04)},
				{field:"ACC_KIND",title:"账户类型",sortable:true},
				{field:"DEAL_DATE",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"CARD_BAL",title:"账户交易前金额",sortable:true,formatter:function(value,row,index){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"END_DEAL_NO",title:"终端交易流水号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"CARD_COUNTER",title:"卡交易序列号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"USER_ID",title:"柜员/终端编号",sortable:true},
				{field:"NAME",title:"柜员/终端名称",sortable:true},
				{field:"CLR_DATE",title:"清分日期",sortable:true},
				{field:"DEAL_STATE",title:"状态",sortable:true},
				{field:"NOTE",title:"备注",sortable:true}
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
            	var i = 0;
            	var maxL = rows.length;
            	for(;i < maxL;i++){
            		calRow(true,rows[i]);
            	}
            	updateFooter();
            },
            onUncheckAll:function(rows){
            	initCal();
            	updateFooter();
            },
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            	initCal();
            	updateFooter();
            }
		});
	});
	function initCal(){
		totalNum = 0;
		totalAmt = 0.00;
	}
	function calRow(is,data){
		if(is){
			totalNum = parseFloat(totalNum) + parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) + parseFloat(data.AMT);
		}else{
			totalNum = parseFloat(totalNum) - parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) - parseFloat(data.AMT);
		}
	}
	function updateFooter(){
		$grid.datagrid("reloadFooter",[{
        	DEAL_CODE:"本页信息统计：",
        	ACC_KIND:"笔数",
        	DEAL_DATE:parseFloat(totalNum),
        	CARD_BAL :"金额",
        	AMT:parseFloat(totalAmt).toFixed(2)}
        ]);
	}
	function query(){
		initCal();
		var params = getformdata("searchConts");
		params["queryType"] = "0"
		$grid.datagrid("load",params);
	}
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		query();
	}
	
	function exportDetail(){
		var selections = $grid.datagrid("getSelections");
		var dealNos = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].DEAL_NO + ",";
			}
		}
		$('#downloadcsv').attr('src','statistical/statisticalAnalysisAction!exportBrchRechargeStatistics.action?queryType=0&rows=20000&dealNos=' + dealNos.substring(0, dealNos.length - 1) + '&' + $("#searchConts").serialize());
	}
</script>
<n:initpage title="卡交易信息进行查询查询操作！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input  id="dealNo" type="text"  class="textinput easyui-validatebox" name="dealNo"/></td>
						<!-- <td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput" name="userId"/></td> -->
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="textinput" name="cardType"/></td>
						<td class="tableleft">账户类型：</td>
						<td class="tableright"><input id="accKind" type="text" class="textinput" name="accKind" value="02"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright">
							<input id="cardNo" type="text" class="textinput" name="cardNo"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableright" colspan="4">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="卡账户流水信息"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>