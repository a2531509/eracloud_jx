<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript"> 
    var $dg;
    var $grid;
    
    function fmoney(s, n) {
    	var tempFlag = "";
    	if(!(s.indexOf("-")<0)){
    		s = s.replace(/\-/, "");
        	tempFlag = "-"; 
    	}
    	n = n > 0 && n <= 20 ? n : 2; 
    	s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + ""; 
    	var l = s.split(".")[0].split("").reverse(), r = s.split(".")[1]; 
    	t = ""; 
    	for (i = 0; i < l.length; i++) { 
    	t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : ""); 
    	} 
    	return tempFlag+t.split("").reverse().join("") + "." + r; 
    } 
	$(function() {
		createRegionSelect({id:"region_Id"});
		
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
		
		createSys_Org(
			{id:"org_Id"},
			{id:"brch_Id"}
		);
		$dg = $("#dg");
		$grid = $dg.datagrid({
			url : "sysReportQuery/sysReportQueryAction!queryBrchRechargeMsg.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageList : [100, 200, 500, 1000, 2000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			view:myview,
			frozenColumns:[
				[
				 	{field:'SEQ',rowspan:3,title:'',checkbox:true},
					{field:'ACPT_ID',title:'受理点',rowspan:3,align:'center',width:parseInt($(this).width()*0.1)},
					{field:'CARD_TYPE',title:'卡类型',rowspan:3,align:'center',width:parseInt($(this).width()*0.06)},
					{title:'联机账户',colspan:12,align:'center',width:parseInt($(this).width()*0.4)}
				],
				[
					{title:'现金充值',colspan:2,align:'center',width:parseInt($(this).width()*0.1)},
					{title:'现金充值撤销',colspan:2,align:'center',width:parseInt($(this).width()*0.1)},
					{title:'银行卡',colspan:2,align:'center',width:parseInt($(this).width()*0.1)},
					{title:'银行卡充值撤销',colspan:2,align:'center',width:parseInt($(this).width()*0.1)},
					{title:'批量充值',colspan:2,align:'center',width:parseInt($(this).width()*0.12)},
					{title:'小计',colspan:2,align:'center',width:parseInt($(this).width()*0.1)}
				], 
				[
					{field:'XJ_RECHARGE_LJ_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.05)},
					{field:'XJ_RECHARGE_LJ_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'XJ_RECHARGE_LJ_CX_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.05)},
					{field:'XJ_RECHARGE_LJ_CX_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'BNAK_RECHARGE_LJ_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.05)},
					{field:'BNAK_RECHARGE_LJ_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'BNAK_RECHARGE_LJ_CX_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.05)},
					{field:'BNAK_RECHARGE_LJ_CX_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'CORP_RECHARGE_LJ_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'CORP_RECHARGE_LJ_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'LJ_TOT_NUM',title:'笔数',align:'center', formatter:function(value, row, index){
						return parseInt(row.XJ_RECHARGE_LJ_NUM) - parseInt(row.XJ_RECHARGE_LJ_CX_NUM) + parseInt(row.BNAK_RECHARGE_LJ_NUM) - parseInt(row.BNAK_RECHARGE_LJ_CX_NUM) + parseInt(row.CORP_RECHARGE_LJ_NUM);
					}},
					{field:'LJ_TOT_AMT',title:'金额',align:'center', formatter:function(value,row,index){
						return fmoney(((parseFloat(row.XJ_RECHARGE_LJ_AMT) + parseFloat(row.XJ_RECHARGE_LJ_CX_AMT) + parseFloat(row.BNAK_RECHARGE_LJ_AMT) + parseFloat(row.BNAK_RECHARGE_LJ_CX_AMT) + parseFloat(row.CORP_RECHARGE_LJ_AMT))/100).toFixed(2));
					}}
	      		]
               ],
		columns :[
				[
					{title:'电子钱包',colspan:10,align:'center',sortable:false,width:parseInt($(this).width()*0.4)},
					{title:'未登账户',colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.4)},
					{title:'总计',rowspan:2,colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.04)}
				],
				[
					{title:'现金充值',colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.1)},
					{title:'现金充值撤销',colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.1)},
					{title:'银行卡',colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.1)},
					{title:'银行卡充值撤销',colspan:2,align:'center',sortable:false,width:parseInt($(this).width()*0.1)},
					{title:'小计',colspan:2,align:'center',width:parseInt($(this).width()*0.1)},
					{title:'批量充值',colspan:2,align:'center',width:parseInt($(this).width()*0.1)}
				],   
				[
					{field:'XJ_RECHARGE_TJ_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'XJ_RECHARGE_TJ_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'XJ_RECHARGE_TJ_CX_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'XJ_RECHARGE_TJ_CX_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'BNAK_RECHARGE_TJ_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'BNAK_RECHARGE_TJ_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'BNAK_RECHARGE_TJ_CX_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'BNAK_RECHARGE_TJ_CX_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'TJ_TOT_NUM',title:'笔数',align:'center', formatter:function(value, row, index){
						return parseInt(row.XJ_RECHARGE_TJ_NUM) - parseInt(row.XJ_RECHARGE_TJ_CX_NUM) + parseInt(row.BNAK_RECHARGE_TJ_NUM) - parseInt(row.BNAK_RECHARGE_TJ_CX_NUM);
					}},
					{field:'TJ_TOT_AMT',title:'金额',align:'center',formatter:function(value,row,index){
						return fmoney(((parseFloat(row.XJ_RECHARGE_TJ_AMT) + parseFloat(row.XJ_RECHARGE_TJ_CX_AMT) + parseFloat(row.BNAK_RECHARGE_TJ_AMT) + parseFloat(row.BNAK_RECHARGE_TJ_CX_AMT))/100).toFixed(2));
					}},
					{field:'BATCH_RECHARGE_UR_NUM',title:'笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'BATCH_RECHARGE_UR_AMT',title:'金额',align:'center',sortable:false,width:parseInt($(this).width()*0.05), formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
					}},
					{field:'TOTAL_NUM',title:'合计笔数',align:'center',sortable:false,width:parseInt($(this).width()*0.05)},
					{field:'TOTAL_AMT',title:'合计金额',align:'center',sortable:false,width:180,formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return fmoney(parseFloat(value/100).toFixed(2));
						}
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
            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
            	  if(data.status != 0){
            		 $.messager.alert('系统消息',data.errMsg,'error');
            	  }else{
            		  $dg.datagrid("autoMergeCells",['ACPT_ID']);
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
		var XJ_RECHARGE_LJ_NUM = 0;
		var XJ_RECHARGE_LJ_AMT = 0;
		var XJ_RECHARGE_LJ_CX_NUM = 0;
		var XJ_RECHARGE_LJ_CX_AMT = 0;
		var BNAK_RECHARGE_LJ_NUM = 0;
		var BNAK_RECHARGE_LJ_AMT = 0;
		var BNAK_RECHARGE_LJ_CX_NUM = 0;
		var BNAK_RECHARGE_LJ_CX_AMT = 0;
		var XJ_RECHARGE_TJ_NUM = 0;
		var XJ_RECHARGE_TJ_AMT = 0;
		var XJ_RECHARGE_TJ_CX_NUM = 0;
		var XJ_RECHARGE_TJ_CX_AMT = 0;
		var BNAK_RECHARGE_TJ_NUM = 0;
		var BNAK_RECHARGE_TJ_AMT = 0;
		var BNAK_RECHARGE_TJ_CX_NUM = 0;
		var BNAK_RECHARGE_TJ_CX_AMT = 0;
		var CORP_RECHARGE_LJ_NUM = 0;
		var CORP_RECHARGE_LJ_AMT = 0;
		var BATCH_RECHARGE_UR_NUM = 0;
		var BATCH_RECHARGE_UR_AMT = 0;
		var TOTAL_NUM = 0;
		var TOTAL_AMT = 0;
		
		var selections = $dg.datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				var r = selections[i];
				XJ_RECHARGE_LJ_NUM += Number(r.XJ_RECHARGE_LJ_NUM);
				XJ_RECHARGE_LJ_AMT += Number(r.XJ_RECHARGE_LJ_AMT);
				XJ_RECHARGE_LJ_CX_NUM += Number(r.XJ_RECHARGE_LJ_CX_NUM);
				XJ_RECHARGE_LJ_CX_AMT += Number(r.XJ_RECHARGE_LJ_CX_AMT);
				BNAK_RECHARGE_LJ_NUM += Number(r.BNAK_RECHARGE_LJ_NUM);
				BNAK_RECHARGE_LJ_AMT += Number(r.BNAK_RECHARGE_LJ_AMT);
				BNAK_RECHARGE_LJ_CX_NUM += Number(r.BNAK_RECHARGE_LJ_CX_NUM);
				BNAK_RECHARGE_LJ_CX_AMT += Number(r.BNAK_RECHARGE_LJ_CX_AMT);
				XJ_RECHARGE_TJ_NUM += Number(r.XJ_RECHARGE_TJ_NUM);
				XJ_RECHARGE_TJ_AMT += Number(r.XJ_RECHARGE_TJ_AMT);
				XJ_RECHARGE_TJ_CX_NUM += Number(r.XJ_RECHARGE_TJ_CX_NUM);
				XJ_RECHARGE_TJ_CX_AMT += Number(r.XJ_RECHARGE_TJ_CX_AMT);
				BNAK_RECHARGE_TJ_NUM += Number(r.BNAK_RECHARGE_TJ_NUM);
				BNAK_RECHARGE_TJ_AMT += Number(r.BNAK_RECHARGE_TJ_AMT);
				BNAK_RECHARGE_TJ_CX_NUM += Number(r.BNAK_RECHARGE_TJ_CX_NUM);
				BNAK_RECHARGE_TJ_CX_AMT += Number(r.BNAK_RECHARGE_TJ_CX_AMT);
				CORP_RECHARGE_LJ_NUM += Number(r.CORP_RECHARGE_LJ_NUM);
				CORP_RECHARGE_LJ_AMT += Number(r.CORP_RECHARGE_LJ_AMT);
				BATCH_RECHARGE_UR_NUM += Number(r.BATCH_RECHARGE_UR_NUM)
				BATCH_RECHARGE_UR_AMT += Number(r.BATCH_RECHARGE_UR_AMT)
				TOTAL_NUM += Number(r.TOTAL_NUM);
				TOTAL_AMT += Number(r.TOTAL_AMT);
			}
		}
		
		$dg.datagrid("reloadFooter", [{
			isFooter : true,
			ACPT_ID : '本页信息统计：',
			XJ_RECHARGE_LJ_NUM : XJ_RECHARGE_LJ_NUM,
			XJ_RECHARGE_LJ_AMT : XJ_RECHARGE_LJ_AMT,
			XJ_RECHARGE_LJ_CX_NUM : XJ_RECHARGE_LJ_CX_NUM,
			XJ_RECHARGE_LJ_CX_AMT : XJ_RECHARGE_LJ_CX_AMT,
			BNAK_RECHARGE_LJ_NUM : BNAK_RECHARGE_LJ_NUM,
			BNAK_RECHARGE_LJ_AMT : BNAK_RECHARGE_LJ_AMT,
			BNAK_RECHARGE_LJ_CX_NUM : BNAK_RECHARGE_LJ_CX_NUM,
			BNAK_RECHARGE_LJ_CX_AMT : BNAK_RECHARGE_LJ_CX_AMT,
			XJ_RECHARGE_TJ_NUM : XJ_RECHARGE_TJ_NUM,
			XJ_RECHARGE_TJ_AMT : XJ_RECHARGE_TJ_AMT,
			XJ_RECHARGE_TJ_CX_NUM : XJ_RECHARGE_TJ_CX_NUM,
			XJ_RECHARGE_TJ_CX_AMT : XJ_RECHARGE_TJ_CX_AMT,
			BNAK_RECHARGE_TJ_NUM : BNAK_RECHARGE_TJ_NUM,
			BNAK_RECHARGE_TJ_AMT : BNAK_RECHARGE_TJ_AMT,
			BNAK_RECHARGE_TJ_CX_NUM : BNAK_RECHARGE_TJ_CX_NUM,
			BNAK_RECHARGE_TJ_CX_AMT : BNAK_RECHARGE_TJ_CX_AMT,
			CORP_RECHARGE_LJ_NUM : CORP_RECHARGE_LJ_NUM,
			CORP_RECHARGE_LJ_AMT : CORP_RECHARGE_LJ_AMT,
			BATCH_RECHARGE_UR_NUM : BATCH_RECHARGE_UR_NUM,
			BATCH_RECHARGE_UR_AMT : BATCH_RECHARGE_UR_AMT,
			TOTAL_NUM : TOTAL_NUM,
			TOTAL_AMT : TOTAL_AMT
		}]);
	}
	
	function query(){
		var params = getformdata("rechargeMsgFrom");
		params["queryType"] = "0";
		$dg.datagrid('load',params);
	}
	//导出结算明细
	function execelRechargeRep(){
		var rows = $dg.datagrid('getChecked');
		var id="";
		if (rows.length>0) {
			for(var i=0;i<rows.length;i++){
				if(i==rows.length-1){
					id=id+"'"+rows[i].SEQ+"'";
				}else{
					id=id+"'"+rows[i].SEQ+"'"+",";
				}
			}
			$.post("sysReportQuery/sysReportQueryAction!setExportParams.action", {id:id}, function(data){
				if(data.status == 0){
					$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
					$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportToExcelRechargeMsg.action?' + $("#rechargeMsgFrom").serialize());
				} else {
					jAlert("导出失败，" + data.errMsg);
				}
			}, "json");
		}else{
			parent.$.messager.show({
				title :"提示",
				msg :"请选择记录!",
				timeout : 1000 * 2
			});
		}
		}
</script>
<n:initpage title="充值情况统计进行查询，</strong><span style='color:red;font-weight:700'>注意：</span>是按照网点级别进行的统计！</span>">
  	<n:center>
  		<div id="tb" style="padding:2px 0">
  			<form id="rechargeMsgFrom">
				<table cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
					<tr>
						<td class="tableleft">所属机构：</td>
						<td class="tableright"><input id="org_Id" type="text" class="textinput" name="org_Id"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="brch_Id" type="text" class="textinput" name="brch_Id"/></td>
						<td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="region_Id" type="text" class="textinput" name="region_Id"/></td>
					</tr>
					<tr>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input  id="startDate" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright"><input id="endDate" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableright" colspan="2" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel"  plain="false" onclick="execelRechargeRep();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id ="dg" title="网点充值情况统计"></table>
  	</n:center>
</n:initpage>
