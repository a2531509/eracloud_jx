<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript"> 
    var $dg;
    var $grid;
    
	$(function() {
		$.autoComplete({
			id:"bankId",
			value:"bank_name",
			text:"bank_id",
			table:"base_bank",
			where:"bank_state = '0' ",
			keyColumn:"bank_id",
			minLength:1
		},"bankName");
		
		$.autoComplete({
			id:"bankName",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0' ",
			keyColumn:"bank_name",
			minLength:1
		},"bankId");
		
		var myview = $.extend({}, $.fn.datagrid.defaults.view, {
		    renderFooter: function(target, container, frozen){
		        var opts = $.data(target, 'datagrid').options;
		        var rows = $.data(target, 'datagrid').footer || [];
		        var fields = $(target).datagrid('getColumnFields', frozen);
		        var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
		         
		        for(var i=0; i<rows.length; i++){
		            var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
		            var style = styleValue ? 'style="' + styleValue + '"' : '';
		            table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
		            table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
		            table.push('</tr>');
		        }
		         
		        table.push('</tbody></table>');
		        $(container).html(table.join(''));
		    }
		});
		
		$dg = $("#dg");
		$grid = $dg.datagrid({
			url : "statistical/statisticalAnalysisAction!bankQcQtQfStat.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageList : [100, 200, 500, 1000, 2000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			fitColumns:true,
			view:myview,
			frozenColumns:[
				[
				 	{field:'SEQ',rowspan:4,title:'',checkbox:true},
				 	{field:'BANK_ID',title:'银行编号',rowspan:4,align:'center',width:'120px'},
					{field:'BANK_NAME',title:'银行名称',rowspan:4,align:'center',width:'150px'},
					{field:'CARD_TYPE',title:'卡类型',rowspan:4,align:'center',width:'80px', formatter:function(v){
						if(v == "<%=Constants.CARD_TYPE_QGN%>"){
							return "全功能卡";
						} else if(v == "<%=Constants.CARD_TYPE_SMZK%>") {
							return "金融市民卡";
						}
						return v;
					}},
				],[],[],[]
			],
			columns:[
				[
					{title:'已对账',colspan:8,align:'center'},
					{title:'未对账',colspan:8,align:'center'},
					{title:'总计',rowspan:3,colspan:2,align:'center'}
				],
				[
					{title:'市民卡账户',colspan:6,align:'center'},
					{title:'已对账合计',colspan:2,align:'center'},
					{title:'市民卡账户',colspan:6,align:'center'},
					{title:'未对账合计',colspan:2,align:'center'}
				],
				[
					{title:'圈存',colspan:2,align:'center'},
					{title:'圈付',colspan:2,align:'center'},
					{title:'圈提',colspan:2,align:'center'},
					{field:'YDZ_NUM',title:'笔数',align:'center', rowspan:2, width:'80px',formatter:function(value,row,index){
						var qcNum = isNaN(row.YDZ_QC_NUM)?0:Number(row.YDZ_QC_NUM);
						var qfNum = isNaN(row.YDZ_QF_NUM)?0:Number(row.YDZ_QF_NUM);
						var qtNum = isNaN(row.YDZ_QT_NUM)?0:Number(row.YDZ_QT_NUM);
						row.YDZ_NUM = qcNum + qfNum + qtNum;
						return row.YDZ_NUM;
					}},
					{field:'YDZ_AMT',title:'金额',align:'center', rowspan:2, width:'80px',formatter:function(value,row,index){
						var qcAmt = isNaN(row.YDZ_QC_AMT)?0:Number(row.YDZ_QC_AMT);
						var qfAmt = isNaN(row.YDZ_QF_AMT)?0:Number(row.YDZ_QF_AMT);
						var qtAmt = isNaN(row.YDZ_QT_AMT)?0:Number(row.YDZ_QT_AMT);
						row.YDZ_AMT = qcAmt + qfAmt + qtAmt;
						return $.foramtMoney(row.YDZ_AMT.div100());
					}},
					{title:'圈存',colspan:2,align:'center'},
					{title:'圈付',colspan:2,align:'center'},
					{title:'圈提',colspan:2,align:'center'},
					{field:'WDZ_NUM',title:'笔数',align:'center', rowspan:2,width:'80px',formatter:function(value,row,index){
						var qcNum = isNaN(row.WDZ_QC_NUM)?0:Number(row.WDZ_QC_NUM);
						var qfNum = isNaN(row.WDZ_QF_NUM)?0:Number(row.WDZ_QF_NUM);
						var qtNum = isNaN(row.WDZ_QT_NUM)?0:Number(row.WDZ_QT_NUM);
						row.WDZ_NUM = qcNum + qfNum + qtNum;
						return row.WDZ_NUM;
					}},
					{field:'WDZ_AMT',title:'金额',align:'center', rowspan:2,width:'80px',formatter:function(value,row,index){
						var qcAmt = isNaN(row.WDZ_QC_AMT)?0:Number(row.WDZ_QC_AMT);
						var qfAmt = isNaN(row.WDZ_QF_AMT)?0:Number(row.WDZ_QF_AMT);
						var qtAmt = isNaN(row.WDZ_QT_AMT)?0:Number(row.WDZ_QT_AMT);
						row.WDZ_AMT = qcAmt + qfAmt + qtAmt;
						return $.foramtMoney(row.WDZ_AMT.div100());
					}}
				],
				[
					{field:'YDZ_QC_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'YDZ_QC_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'YDZ_QF_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'YDZ_QF_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'YDZ_QT_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'YDZ_QT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'WDZ_QC_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'WDZ_QC_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'WDZ_QF_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'WDZ_QF_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'WDZ_QT_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'WDZ_QT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'TOT_NUM',title:'笔数',align:'center',width:'80px',formatter:function(value,row,index){
						return row.YDZ_NUM + row.WDZ_NUM;
					}},
					{field:'TOT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						return $.foramtMoney((row.YDZ_AMT + row.WDZ_AMT).div100());
					}}
				]
			],
			toolbar:'#tb',
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			onSelect:function(index,data){
				updateFooter();
            },
            onUnselect:function(index,data){
            	updateFooter();
            },
            onSelectAll:function(rows){
            	updateFooter();
            },
            onUnselectAll:function(rows){
            	updateFooter();
            },
			onLoadSuccess:function(data){
			$grid.datagrid("autoMergeCells",["BANK_ID","BANK_NAME"]);
         	if(data.status != 0) {
           		$.messager.alert('系统消息',data.errMsg,'error');
           		} else {
            		$dg.datagrid("autoMergeCells",['ACPT_ID']);
            	}
            	updateFooter();
            }
		});
		
	});
	
	function updateFooter(){
		var selections = $("#dg").datagrid("getSelections");
		
		var YDZ_QC_NUM = 0;
		var YDZ_QC_AMT = 0;
		var YDZ_QF_NUM = 0;
		var YDZ_QF_AMT = 0;
		var YDZ_QT_NUM = 0;
		var YDZ_QT_AMT = 0;
		var YDZ_NUM = 0;
		var YDZ_AMT = 0;
		
		var WDZ_QC_NUM = 0;
		var WDZ_QC_AMT = 0;
		var WDZ_QF_NUM = 0;
		var WDZ_QF_AMT = 0;
		var WDZ_QT_NUM = 0;
		var WDZ_QT_AMT = 0;
		var WDZ_NUM = 0;
		var WDZ_AMT = 0;
		
		var TOT_NUM = 0;
		var TOT_AMT = 0;
		
		var num = 0;
		for(var i in selections){
			num++;
			
			var row = selections[i];
			
			YDZ_QC_NUM += isNaN(Number(row.YDZ_QC_NUM))?0:Number(row.YDZ_QC_NUM);
			YDZ_QC_AMT += isNaN(Number(row.YDZ_QC_AMT))?0:Number(row.YDZ_QC_AMT);
			YDZ_QF_NUM += isNaN(Number(row.YDZ_QF_NUM))?0:Number(row.YDZ_QF_NUM);
			YDZ_QF_AMT += isNaN(Number(row.YDZ_QF_AMT))?0:Number(row.YDZ_QF_AMT);
			YDZ_QT_NUM += isNaN(Number(row.YDZ_QT_NUM))?0:Number(row.YDZ_QT_NUM);
			YDZ_QT_AMT += isNaN(Number(row.YDZ_QT_AMT))?0:Number(row.YDZ_QT_AMT);
			YDZ_NUM += isNaN(Number(row.YDZ_NUM))?0:Number(row.YDZ_NUM);
			YDZ_AMT += isNaN(Number(row.YDZ_AMT))?0:Number(row.YDZ_AMT);
			
			WDZ_QC_NUM += isNaN(Number(row.WDZ_QC_NUM))?0:Number(row.WDZ_QC_NUM);
			WDZ_QC_AMT += isNaN(Number(row.WDZ_QC_AMT))?0:Number(row.WDZ_QC_AMT);
			WDZ_QF_NUM += isNaN(Number(row.WDZ_QF_NUM))?0:Number(row.WDZ_QF_NUM);
			WDZ_QF_AMT += isNaN(Number(row.WDZ_QF_AMT))?0:Number(row.WDZ_QF_AMT);
			WDZ_QT_NUM += isNaN(Number(row.WDZ_QT_NUM))?0:Number(row.WDZ_QT_NUM);
			WDZ_QT_AMT += isNaN(Number(row.WDZ_QT_AMT))?0:Number(row.WDZ_QT_AMT);
			WDZ_NUM += isNaN(Number(row.WDZ_NUM))?0:Number(row.WDZ_NUM);
			WDZ_AMT += isNaN(Number(row.WDZ_AMT))?0:Number(row.WDZ_AMT);
			
			TOT_NUM += isNaN(Number(row.TOT_NUM))?0:Number(row.TOT_NUM);
			TOT_AMT += isNaN(Number(row.TOT_AMT))?0:Number(row.TOT_AMT);
		}
		
		$("#dg").datagrid("reloadFooter", [{
			isFooter : true,
			CO_ORG_ID : "统计：",
			CO_ORG_NAME : "共 " + num + " 笔",
			YDZ_QC_NUM : YDZ_QC_NUM,
			YDZ_QC_AMT : YDZ_QC_AMT,
			YDZ_QF_NUM : YDZ_QF_NUM,
			YDZ_QF_AMT : YDZ_QF_AMT,
			YDZ_QT_NUM : YDZ_QT_NUM,
			YDZ_QT_AMT : YDZ_QT_AMT,
			YDZ_NUM : YDZ_NUM,
			YDZ_AMT : YDZ_AMT,
			WDZ_QC_NUM : WDZ_QC_NUM,
			WDZ_QC_AMT : WDZ_QC_AMT,
			WDZ_QF_NUM : WDZ_QF_NUM,
			WDZ_QF_AMT : WDZ_QF_AMT,
			WDZ_QT_NUM : WDZ_QT_NUM,
			WDZ_QT_AMT : WDZ_QT_AMT,
			WDZ_NUM : WDZ_NUM,
			WDZ_AMT : WDZ_AMT,
			TOT_NUM : TOT_NUM,
			TOT_AMT : TOT_AMT
		}]);
	}
	
	function query(){
		var params = getformdata("rechargeMsgFrom");
		params["queryType"] = "0";
		$dg.datagrid('load',params);
	}
	//导出结算明细
	function execelRechargeRep(){
		var selections = $dg.datagrid("getSelections");
		var bankIds = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				bankIds += selections[i].BANK_ID + ",";
			}
		}
		$('#downloadcsv').attr('src','statistical/statisticalAnalysisAction!exportBankQcQtQfStat.action?rows=2000&bankIds=' + bankIds.substring(0, bankIds.length - 1) + '&' + $("#rechargeMsgFrom").serialize());
	}
</script>
<n:initpage title="银行圈存圈提圈付统计">
  	<n:center>
  		<div id="tb" style="padding:2px 0">
  			<form id="rechargeMsgFrom">
				<table cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
					<tr>
						<td class="tableleft">银行编号：</td>
						<td class="tableright"><input id="bankId" type="text" class="textinput" name="bankId"/></td>
						<td class="tableleft">银行名称：</td>
						<td class="tableright"><input id="bankName" type="text" class="textinput" name="bankName"/></td>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input  id="startDate" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright"><input id="endDate" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
					</tr>
					<tr>
						<td class="tableright" colspan="8" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel"  plain="false" onclick="execelRechargeRep();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id ="dg" title="银行圈存圈提圈付统计"></table>
	  	<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>