<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$.autoComplete({
			id:"coOrgId",
			value:"co_Org_Name",
			text:"co_Org_Id",
			table:"base_co_org",
			where:"co_state = '0' ",
			keyColumn:"co_Org_Id",
			minLength:1
		},"coOrgName");
		
		$.autoComplete({
			id:"coOrgName",
			value:"co_Org_Id",
			text:"co_Org_Name",
			table:"base_co_org",
			where:"co_state = '0' ",
			keyColumn:"co_Org_Name",
			minLength:1
		},"coOrgId");
		$grid = createDataGrid({
			id:"dg",
			url:"sysReportQuery/sysReportQueryAction!coCorgRechargeCompeare.action",
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
			columns:[
			    [
					{field:"V_V",rowspan:2,checkbox:true},
					{field:"CO_ORG_NAME",rowspan:2,title:"合作机构名称",sortable:true},
			    	{title:"本期充值金额",colspan:3,sortable:true,align:"center",width:parseInt($(this).width() * 0.08)},
			    	{title:"去年同期充值金额",colspan:2,sortable:true,align:"center",width:parseInt($(this).width() * 0.08)},
			    	{title:"本年累计充值金额",colspan:3,sortable:true,align:"center",width:parseInt($(this).width() * 0.08)},
			    	{title:"去年同期充值金额",colspan:2,sortable:true,align:"center",width:parseInt($(this).width() * 0.08)}
			    ],
			    [
					{field:"CUR_PERIOD_TJ_RECHARGE",title:"电子钱包",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}},
					{field:"CUR_PERIOD_LJ_RECHARGE",title:"联机账户",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}},
					{field:"CUR_TOTAL",title:"合计",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((Number(row.CUR_PERIOD_TJ_RECHARGE) + Number(row.CUR_PERIOD_LJ_RECHARGE)).div100());
					}},
					{field:"OLD_AMT",title:"充值金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((Number(row.LAST_PERIOD_LJ_RECHARGE) + Number(row.LAST_PERIOD_TJ_RECHARGE)).div100());
					}},
					{field:"CUR_COMPARE_INFO",title:"同比",align:"center",sortable:true,width:parseInt($(this).width() * 0.06), formatter:function(value, row, index){
						var cl = isNaN(row.CUR_PERIOD_LJ_RECHARGE) ? 0 : row.CUR_PERIOD_LJ_RECHARGE;
						var ct = isNaN(row.CUR_PERIOD_TJ_RECHARGE) ? 0 : row.CUR_PERIOD_TJ_RECHARGE;
						var ll = isNaN(row.LAST_PERIOD_LJ_RECHARGE) ? 0 : row.LAST_PERIOD_LJ_RECHARGE;
						var lt = isNaN(row.LAST_PERIOD_TJ_RECHARGE) ? 0 : row.LAST_PERIOD_TJ_RECHARGE;
						var c = (cl + ct - ll - lt)/(ll + lt);
						if(ll + lt == 0){
							return;
						}
						return (isNaN(c) ? 0 : c) + "%";
					}},
					{field:"CUR_YEAR_TJ_RECHARGE",title:"电子钱包",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}},
					{field:"CUR_YEAR_LJ_RECHARGE",title:"联机账户",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}},
					{field:"ALL_TOTAL",title:"合计",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((Number(row.CUR_YEAR_TJ_RECHARGE) + Number(row.CUR_YEAR_LJ_RECHARGE)).div100());
					}},
					{field:"OLDALL_AMT",title:"充值金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number((row.LAST_YEAR_TJ_RECHARGE) + Number(row.LAST_YEAR_LJ_RECHARGE)).div100());
					}},
					{field:"OLD_COMPARE_INFO",title:"同比",align:"center",sortable:true,width:parseInt($(this).width() * 0.06), formatter:function(v, row, i){
						var cl = isNaN(row.CUR_YEAR_LJ_RECHARGE) ? 0 : row.CUR_YEAR_LJ_RECHARGE;
						var ct = isNaN(row.CUR_YEAR_TJ_RECHARGE) ? 0 : row.CUR_YEAR_TJ_RECHARGE;
						var ll = isNaN(row.LAST_YEAR_LJ_RECHARGE) ? 0 : row.LAST_YEAR_LJ_RECHARGE;
						var lt = isNaN(row.LAST_YEAR_TJ_RECHARGE) ? 0 : row.LAST_YEAR_TJ_RECHARGE;
						if(ll + lt == 0){
							return;
						}
						var c = (cl + ct - ll - lt)/(ll + lt);
						return (isNaN(c) ? 0 : c) + "%";
					}}
			    ]
			],
			onLoadSuccess:function(data){
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
		var CUR_PERIOD_LJ_RECHARGE = 0;
		var CUR_PERIOD_TJ_RECHARGE = 0;
		var LAST_PERIOD_LJ_RECHARGE = 0;
		var LAST_PERIOD_TJ_RECHARGE = 0;
		var CUR_YEAR_LJ_RECHARGE = 0;
		var CUR_YEAR_TJ_RECHARGE = 0;
		var LAST_YEAR_LJ_RECHARGE = 0;
		var LAST_YEAR_TJ_RECHARGE = 0;
		var selection = $("#dg").datagrid("getSelections");
		if(selection){
			for(var i in selection){
				var r = selection[i];
				CUR_PERIOD_LJ_RECHARGE += isNaN(r.CUR_PERIOD_LJ_RECHARGE)?0:Number(r.CUR_PERIOD_LJ_RECHARGE);
				CUR_PERIOD_TJ_RECHARGE += isNaN(r.CUR_PERIOD_TJ_RECHARGE)?0:Number(r.CUR_PERIOD_TJ_RECHARGE);
				LAST_PERIOD_LJ_RECHARGE += isNaN(r.LAST_PERIOD_LJ_RECHARGE)?0:Number(r.LAST_PERIOD_LJ_RECHARGE);
				LAST_PERIOD_TJ_RECHARGE += isNaN(r.LAST_PERIOD_TJ_RECHARGE)?0:Number(r.LAST_PERIOD_TJ_RECHARGE);
				CUR_YEAR_LJ_RECHARGE += isNaN(r.CUR_YEAR_LJ_RECHARGE)?0:Number(r.CUR_YEAR_LJ_RECHARGE);
				CUR_YEAR_TJ_RECHARGE += isNaN(r.CUR_YEAR_TJ_RECHARGE)?0:Number(r.CUR_YEAR_TJ_RECHARGE);
				LAST_YEAR_LJ_RECHARGE += isNaN(r.LAST_YEAR_LJ_RECHARGE)?0:Number(r.LAST_YEAR_LJ_RECHARGE);
				LAST_YEAR_TJ_RECHARGE += isNaN(r.LAST_YEAR_TJ_RECHARGE)?0:Number(r.LAST_YEAR_TJ_RECHARGE);
			}
		}
		$("#dg").datagrid("reloadFooter", [{
			CO_ORG_NAME:"统计",
			CUR_PERIOD_LJ_RECHARGE : CUR_PERIOD_LJ_RECHARGE,
			CUR_PERIOD_TJ_RECHARGE : CUR_PERIOD_TJ_RECHARGE,
			LAST_PERIOD_LJ_RECHARGE : LAST_PERIOD_LJ_RECHARGE,
			LAST_PERIOD_TJ_RECHARGE : LAST_PERIOD_TJ_RECHARGE,
			CUR_YEAR_LJ_RECHARGE : CUR_YEAR_LJ_RECHARGE,
			CUR_YEAR_TJ_RECHARGE : CUR_YEAR_TJ_RECHARGE,
			LAST_YEAR_LJ_RECHARGE : LAST_YEAR_LJ_RECHARGE,
			LAST_YEAR_TJ_RECHARGE : LAST_YEAR_TJ_RECHARGE
		}]);
	}
	function query(){
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
		var coOrgIds = "";
		if(selection){
			for(var i in selection){
				coOrgIds += selection[i].BRCH_ID + ",";
			}
			coOrgIds = coOrgIds.substring(0, coOrgIds.length - 1);
		}
		if(!coOrgIds){
			$.messager.confirm("系统消息", "确定导出当前所有数据吗？", function(r){
				if(r){
					$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
					$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportCoOrgRechargeCompeareReport.action?' + $("#searchConts").serialize() + "&page=1&rows=10000");
				}
			})
		} else {
			$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
			$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportCoOrgRechargeCompeareReport.action?' + $("#searchConts").serialize() + "&checkIds=" + coOrgIds + "&page=1&rows=10000");
		}
	}
</script>
<n:initpage title="合作机构充值同比对比进行查询及导出！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid" style="width: 100%;">
					<tr>
						<td class="tableleft">合作机构编号：</td>
						<td class="tableright"><input id="coOrgId" type="text" class="textinput" name="coOrgId"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input id="coOrgName" type="text" class="textinput" name="coOrgName"/></td>
						<td class="tableleft">起始月份</td>
						<td class="tableright">
							<input id="qyMonth" name="qyMonth" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM',maxDate:'%y-%M'})"/>
						</td>
						<td class="tableleft">结束月份</td>
						<td class="tableright">
							<input id="qyMonthEnd" name="qyMonthEnd" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM',minDate:'#F{$dp.$D(\'qyMonth\')}',maxDate:'%y-%M'})"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportReport()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="合作机构充值同比对比" style="width:100%"></</table>
	</n:center>
</n:initpage>