<%@page import="com.erp.util.DealCode"%>
<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	var $dg;
	var $grid;
	$(function() {
		//$.createDealCode("dealCode");
		$("#deal_Code").combobox({
				textField:"text",
				valueField:"value",
				data:[{value:'',text:"请选择"},{value:'1',text:"市民卡账户转市民卡钱包"},{value:'2',text:"市民卡钱包转市民卡账户"},{value:'3',text:"未登账户转市民卡钱包"}],
				panelHeight:"auto",
				editable:false
			});
		 
		$("#acptType").combobox({
			textField:"text",
			valueField:"value",
			data:[
				{value:"", text:"请选择"},
				{value:"1", text:"网点"},
				{value:"2", text:"合作机构"}
			],
			panelHeight:"auto",
			editable:false,
			onChange:function(value){
				if(!value){
					$(".brch_org").hide();
				}else if (value == "1"){
					$(".branchName").show();
					$(".org_Id").hide();
				}else if (value == "2"){
					$(".org_Id").show();
					$(".branchName").hide();
				}
			}
		});
		
		createSysBranch({
			id:"branchId"},{
			id:"userId"
		});

		$.autoComplete({
			id:"org_Id",
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
		},"org_Id");
		
		$("#Wdate").tooltip({
            content:"<span style='color:#B94A48'>导出当前条件所有数据</span>"
        });
		
		
		$dg = $("#dg");
		$grid = $dg.datagrid({
			url:"sysReportQuery/sysReportQueryAction!querytransferStatisticsMsg.action",
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
			columns:[
				[
				 	{field:'',title:'',checkbox:true},
					{field:'ACPT_ID',title:'受理点编号',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'ACPT_NAME',title:'受理点名称',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'ACPT_TYPE',title:'受理点类型',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'CARD_TYPE',title:'卡类型',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'TOT_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'TOT_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}}
	      		]
			],
			toolbar:'#tb',
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			onLoadSuccess:function(data){
            	if(data.status != 0){
            		$.messager.alert('系统消息',data.errMsg,'error');
            	}else{
                    $grid.datagrid("autoMergeCells",["ACPT_ID","ACPT_NAME"]);
                    updateFooter();
                }
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
            },
            onBeforeLoad:function(params){
            	if(!params.query){
            		return false;
            	} else if(!params.startDate || !params.endDate){
            		jAlert("起始日期和结束日期不能为空！", "warning");
            		return false;
            	}
            }
		});
	})
	
	function updateFooter(){
		var TOTAL_NUM = 0;
		var TOTAL_AMT = 0;
		
		var selections = $dg.datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				var r = selections[i];
				TOTAL_NUM += Number(r.TOT_NUM);
				TOTAL_AMT += Number(r.TOT_AMT);
			}
		}
		
		$dg.datagrid("reloadFooter", [{
			isFooter : true,
			ACPT_ID : '本页信息统计：',
			TOT_NUM : TOTAL_NUM,
			TOT_AMT : TOTAL_AMT
		}]);
	}
	
	function query(){
		var params = getformdata("walletRechargeMsgFrom");
		params["query"] = true;
		$dg.datagrid('load',params);
	}
	
	//导出明细
	function execelRechargeRep(){
		$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportquerytransferStatisticsMsg.action?queryType=0&rows=20000&' + $("#walletRechargeMsgFrom").serialize());
	}
	
	
</script>
<n:initpage title="转账统计查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="walletRechargeMsgFrom">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">受理点类型：</td>
						<td class="tableright"><input id="acptType" type="textinput" class="textinput" name="acptType" /></td>
						<td class="tableleft brch_org branchName" style="display: none">&nbsp;&nbsp;网点名称：</td>
						<td class="tableright brch_org branchName" style="display: none"><input id="branchId" type="text" name="brch_Id" class="textinput"/></td>
						<td class="tableleft">业务类型：</td>
						<td class="tableright"><input id="deal_Code" type="text" class="textinput" name="deal_Code"/></td>
						<td class="tableleft brch_org org_Id" style="display: none">合作机构编号：</td>
						<td class="tableright brch_org org_Id" style="display: none"><input id="org_Id" type="text" name="org_Id" class="textinput"/></td>
						<td class="tableleft brch_org org_Id" style="display: none">合作机构名称：</td>
						<td class="tableright brch_org org_Id" style="display: none"><input id="coOrgName" type="text" name="coOrgName" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input  id="startDate" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright"><input id="endDate" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableright" colspan="4" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel"  plain="false" id = 'Wdate' onclick="execelRechargeRep();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="转账统计查询"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>