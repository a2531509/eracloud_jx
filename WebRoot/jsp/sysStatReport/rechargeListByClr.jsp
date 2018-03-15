<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function() {
		$("#acptType").combobox({
			textField:"text",
			valueField:"value",
			data:[
				{value:"1", text:"网点"},
				{value:"2", text:"合作机构"}
			],
			value:"1",
			panelHeight:"auto",
			editable:false,
			onChange:function(){
				$(".brch_org").toggle();
				$(".brch_org:visible input").prop("disabled", false);
				$(".brch_org:hidden input").prop("disabled", true);
			}
		});
		
		createSysBranch({
			id:"branchId"},{
			id:"userId"
		});

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

		$("#dg").datagrid({
			url:"statistical/statisticalAnalysisAction!qbRechgByClr.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[100, 200, 500, 1000, 2000, 5000],
			showFooter:true,
			rowStyler: function(index, row){
				if(!row.isFooter && !row.ACPT_ID2){
					return 'background-color:orange; color:#fff;';
				}
			},
			frozenColumns:[[
					{field:"CUSTOMER_ID1", checkbox:true, rowspan:2},
					{field:"DEAL_NO",title:"交易流水", rowspan:2, sortable:true,width:parseInt($(this).width()*0.08)},
					{field:"CUSTOMER_ID",title:"客户编号", rowspan:2, hidden:true, sortable:true,width:parseInt($(this).width()*0.08)},
					{field:"NAME",title:"客户姓名", rowspan:2, sortable:true,width:parseInt($(this).width()*0.08)},
					{field:"CERT_NO",title:"证件号码", rowspan:2, sortable:true,width:parseInt($(this).width()*0.15)}],[]],
			columns:[[
					{title:"清分数据（统计）", colspan:11},
					{title:"交易数据（查询）", colspan:10},
			    ], [
					{field:"ACPT_ID",title:"受理点编号", sortable:true},
					{field:"ACPT_NAME", title:"受理点", sortable:true},
					{field:"DEAL_CODE_NAME", title:"业务类型", sortable:true},
					{field:"CARD_NO", title:"卡号", sortable:true},
					{field:"CARD_TYPE", title:"卡类型", sortable:true},
					{field:"ACC_KIND", title:"账户类型", sortable:true},
					{field:"CR_ACC_BAL", title:"交易前金额", sortable:true, formatter:function(v, row){
						if(row.isFooter){
							return;
						}
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"CR_AMT", title:"交易金额", sortable:true, formatter:function(v, row){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"DEAL_DATE", title:"交易时间", sortable:true},
					{field:"CLR_DATE", title:"清分时间", sortable:true},
					{field:"DEAL_STATE", title:"交易状态", sortable:true, formatter:function(v){
						if(v == "0"){
							return "正常";
						} else if(v == "1"){
							return "撤销";
						} else if(v == "2"){
							return "冲正";
						} else if(v == "3"){
							return "退货";
						} else if(v == "9"){
							return "灰记录";
						}
					}},
					{field:"ACPT_ID2",title:"受理点编号", sortable:true},
					{field:"ACPT_NAME2",title:"受理点", sortable:true},
					{field:"CARD_NO2",title:"卡号", sortable:true},
					{field:"CARD_TYPE2",title:"卡类型", sortable:true},
					{field:"ACC_KIND2",title:"账户类型", sortable:true},
					{field:"ACC_BAL2",title:"交易前金额", sortable:true, formatter:function(v, row){
						if(row.isFooter){
							return;
						}
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"AMT2",title:"交易金额", sortable:true, formatter:function(v, row){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"DEAL_DATE2", title:"交易时间", sortable:true},
					{field:"CLR_DATE2", title:"清分时间", sortable:true},
					{field:"DEAL_STATE2", title:"交易状态", sortable:true, formatter:function(v){
						if(v == "0"){
							return "正常";
						} else if(v == "1"){
							return "撤销";
						} else if(v == "2"){
							return "冲正";
						} else if(v == "3"){
							return "退货";
						} else if(v == "9"){
							return "灰记录";
						}
					}}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            	updateFooter();
            },
            onSelect:updateFooter,
            onUnselect:updateFooter,
            onSelectAll:updateFooter,
            onUnselectAll:updateFooter,
		});
	})
	
	function updateFooter(){
		var count = 0;
		var count2 = 0;
		var sumAmt = 0;
		var sumAmt2 = 0;
		var selections = $("#dg").datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				count++;
				if(selections[i].ACPT_ID2){
					count2++;
				}
				sumAmt += isNaN(selections[i].CR_AMT)?0:Number(selections[i].CR_AMT);
				sumAmt2 += isNaN(selections[i].AMT2)?0:Number(selections[i].AMT2);
			}
		}
		$("#dg").datagrid("reloadFooter", [{isFooter:true, CR_AMT:sumAmt, AMT2:sumAmt2, CARD_NO:"共 " + count + " 条记录", CARD_NO2:"共 " + count2 + " 条记录"}]);
	}
	
	function query() {
		
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		if(!params.clrStartDate){
			jAlert("请选择清分日期！", "warning");
			return;
		}
		params.name = $("#name").val();
		params.query = true;
		$("#dg").datagrid("load", params);
	}
	
	function exportDetail(){
		var selection = $("#dg").datagrid("getSelections");
		var dealNos = "";
		if(selection){
			for(var i in selection){
				dealNos += selection[i].DEAL_NO + ",";
			}
			dealNos = dealNos.substring(0, dealNos.length - 1);
		}
		if(dealNos){
			dealNos = dealNos.substring(0);
		}
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		params["rows"] = 65000;
		params["dealNo"] = dealNos;
		
		var paraStr = "";
		for(var i in params){
			paraStr += "&" + i + "=" + params[i];
		}
		$.messager.progress({text:"数据处理中..."});
		$('#download').attr('src',"statistical/statisticalAnalysisAction!exportqbRechgByClrInfo.action?" + paraStr.substring(1));
		startCycle();
	}

	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportqbRechgByClrInfo",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	
	
</script>
<n:initpage title="每个月钱包充值清分 / 交易数据！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">受理点类型：</td>
						<td class="tableright"><input id="acptType" type="textinput" class="textinput" name="acptType" /></td>
						<td class="tableleft brch_org">&nbsp;&nbsp;网点名称：</td>
						<td class="tableright brch_org">
						<input id="branchId" type="text" name="branchId" class="textinput"/></td>
						<td class="tableleft brch_org">&nbsp;&nbsp;柜员名称：</td>
						<td class="tableright brch_org"><input id="userId" type="text" name="userId" class="textinput"/></td>
						<td class="tableleft brch_org" style="display: none">合作机构编号：</td>
						<td class="tableright brch_org" style="display: none"><input id="coOrgId" type="text" name="coOrgId" class="textinput"/></td>
						<td class="tableleft brch_org" style="display: none">合作机构名称：</td>
						<td class="tableright brch_org" style="display: none"><input id="coOrgName" type="text" name="coOrgName" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">清分时间：</td>
						<td class="tableright">
							<input  id="clrDate" type="text" name="clrStartDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM',qsEnabled:false,maxDate:'%y-%M'})"/>
						</td>
						<td class="tableright" colspan="4" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="卡片参保信息"></table>
  		<iframe id="download" style="display:none"></iframe>
  	</n:center>
</n:initpage>