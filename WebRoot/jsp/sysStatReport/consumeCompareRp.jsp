<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 消费比对报表 -->
<script type="text/javascript">
	var $grid;
	$(function(){
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

		$grid = createDataGrid({
			id:"dg",
			url:"sysReportQuery/sysReportQueryAction!rechargeCompeareRp.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			fitColumns:true,
			singleSelect:false,
			scrollbarSize:0,
			pageSize:50,
			autoRowHeight:true,
			pageList:[50,1000,2000,3000,5000],
			showFooter:true,
			frozenColumns:[
			    [
					{field:"V_V",rowspan:2,checkbox:true},
					{field:"MERCHANT_NAME",rowspan:2,title:"商户名称",sortable:true, width:200},
					{field:"FEE_RATE",rowspan:2,title:"费率",sortable:true, width:410}
			    ],[]
			],
			columns : [[
						{title:"本期交易",colspan:5,sortable:true,align:"center"},
						{title:"本年累计",colspan:5,sortable:true,align:"center"}
			        ],[
						{field:"CUR_NUM",title:"交易笔数",align:"center",sortable:true},
						{field:"CUR_AMT",title:"交易金额",align:"left",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"OLD_AMT",title:"去年同期",align:"center",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"CUR_COP_INFO",title:"同比%",align:"center",sortable:true},
						{field:"CUR_FEE",title:"手续费",align:"center",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"CUR_TOT_NUM",title:"交易笔数",align:"center",sortable:true},
						{field:"CUR_TOT_AMT",title:"交易金额",align:"center",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"OLD_TOT_AMT",title:"去年同期",align:"center",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"TOT_COP_INFO",title:"同比%",align:"center",sortable:true},
						{field:"CUR_YEAR_FEE",title:"手续费",align:"center",sortable:true,formatter:function(value,row,index){
							return $.foramtMoney(Number(value).div100());
						}}
				    ]],
			onLoadSuccess:function(data){
				$grid.datagrid("autoMergeCells",["FULL_NAME","BRCH_ID"]);
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
				}
				updateFooter();
			},
			onSelect:function(){
				updateFooter();
			},
			onUnselect:function(){
				updateFooter();
			},
			onSelectAll:function(){
				updateFooter();
			},
			onUnselectAll:function(){
				updateFooter();
			}
		});
	});
	function updateFooter(){
		var curNum = 0;
		var curAmt = 0;
		var lastAmt = 0
		var curFee = 0;
		var curYearNum = 0;
		var curYearAmt = 0;
		var lastYearAmt = 0
		var curYearFee = 0;
		var num = 0;
		var curCopInfo, totCopInfo;
		var selection = $("#dg").datagrid("getSelections");
		if(selection){
			for(var i in selection){
				var r = selection[i];
				num++;
				curNum += isNaN(r.CUR_NUM)?0:Number(r.CUR_NUM);
				curAmt += isNaN(r.CUR_AMT)?0:Number(r.CUR_AMT);
				lastAmt += isNaN(r.OLD_AMT)?0:Number(r.OLD_AMT);
				curFee += isNaN(r.CUR_FEE)?0:Number(r.CUR_FEE);
				curYearNum += isNaN(r.CUR_TOT_NUM)?0:Number(r.CUR_TOT_NUM);
				curYearAmt += isNaN(r.CUR_TOT_AMT)?0:Number(r.CUR_TOT_AMT);
				lastYearAmt += isNaN(r.OLD_TOT_AMT)?0:Number(r.OLD_TOT_AMT);
				curYearFee += isNaN(r.CUR_YEAR_FEE)?0:Number(r.CUR_YEAR_FEE);
			}
		}
		if(lastAmt == 0){
			curCopInfo = "";
		}else{
			curCopInfo = ((curAmt-lastAmt)/lastAmt*100).toFixed(2) + "%"
		}
		if(lastYearAmt == 0){
			totCopInfo = "";
		}else{
			totCopInfo = ((curYearAmt-lastYearAmt)/lastYearAmt*100).toFixed(2) + "%"
		}
		$("#dg").datagrid("reloadFooter", [{
			MERCHANT_NAME:"统计：",
			FEE_RATE:"共 " + num + " 个商户",
			CUR_NUM:curNum,
			CUR_AMT:curAmt,
			OLD_AMT:lastAmt,
			CUR_FEE:curFee,
			CUR_TOT_NUM:curYearNum,
			CUR_TOT_AMT:curYearAmt,
			OLD_TOT_AMT:lastYearAmt,
			CUR_YEAR_FEE:curYearFee,
			CUR_COP_INFO:curCopInfo,
			TOT_COP_INFO:totCopInfo
		}]);
	}
	function query(){
		if(dealNull($("#qyMonth").val()) == ""){
			jAlert("请输入查询月份！",function(){
				$("#qyMonth").focus();
			});
			return;
		} else if(dealNull($("#qyMonthEnd").val()) == ""){
			jAlert("请输入结束月份！",function(){
				$("#qyMonthEnd").focus();
			});
			return;
		}
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	
	function exportReport(){
		if(dealNull($("#qyMonth").val()) == ""){
			jAlert("请输入起始月份！",function(){
				$("#qyMonth").focus();
			});
			return;
		} else if(dealNull($("#qyMonthEnd").val()) == ""){
			jAlert("请输入结束月份！",function(){
				$("#qyMonthEnd").focus();
			});
			return;
		}
		var selection = $("#dg").datagrid("getSelections");
		var merchantIds = "";
		if(selection){
			for(var i in selection){
				merchantIds += selection[i].MERCHANT_ID + ",";
			}
			merchantIds = merchantIds.substring(0, merchantIds.length - 1);
		}
		if(!merchantIds){
			$.messager.confirm("系统消息", "确定导出当前所有数据吗？", function(r){
				if(r){
					$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
					$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportMerchantConsumeCompareReport.action?' + $("#searchConts").serialize() + "&page=1&rows=10000");
				}
			})
		} else {
			$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
			$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportMerchantConsumeCompareReport.action?' + $("#searchConts").serialize() + "&checkIds=" + merchantIds + "&page=1&rows=10000");
		}
	}
</script>
<n:initpage title="对消费汇总的同步对比！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid" style="width: 100%;">
					<tr >
						<td class="tableleft">商户号：</td>
						<td class="tableright"><input id="merchantId" name="merchantId" class="textinput" /></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input id="merchantName" class="textinput" /></td>
						<td class="tableleft">起始月份</td>
						<td class="tableright">
							<input id="qyMonth" name="qyMonth" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM',maxDate:'%y-%M'})"/>
						</td>
						<td class="tableleft">结束月份</td>
						<td class="tableright">
							<input id="qyMonthEnd" name="qyMonthEnd" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM',maxDate:'%y-%M',minDate:'#F{$dp.$D(\'qyMonth\')}'})"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportReport()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="消费同比对比信息" style="width:100%"></</table>
	</n:center>
</n:initpage>