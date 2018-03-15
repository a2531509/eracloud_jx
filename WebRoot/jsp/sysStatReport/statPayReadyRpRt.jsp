<%@page import="com.erp.util.DateUtil"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
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
		
		$grid = $("#dg").datagrid({
			url:"sysReportQuery/sysReportQueryAction!querySysPayReadyRpRt.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageSize:20,
			singleSelect:false,
			autoRowHeight:true,
			fitColumns:true,
			showFooter:true,
			view:myview,
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			frozenColumns:[[
			            {field:"accKind",title:"账户类型", rowspan:3, align:'center',width:parseInt($(this).width() * 0.1)},
			            {title:"收入", colspan:8, align:'center'}
			        ],[
			            {title:"充值收入", colspan:2, align:'center'},
			            {title:"补账收入", colspan:2, align:'center'},
			            {title:"转账收入", colspan:2, align:'center'},
			            {title:"收入小计", colspan:2, align:'center'}
			        ],[	
				    	{field:"in_r_tot_num",title:"笔数", align:'center',width:80, formatter:function(value, row){
				    		var num = isNaN(row.in_r_num) ? 0 : row.in_r_num;
				    		var num2 = isNaN(row.out_cx_num) ? 0 : row.out_cx_num;
				    		return Number(num) - Number(num2);
				    	}},
				    	{field:"in_r_tot_amt",title:"金额", align:'center',width:80, formatter:function(value, row){
				    		var num = isNaN(row.in_r_amt) ? 0 : row.in_r_amt;
				    		var num2 = isNaN(row.out_cx_amt) ? 0 : row.out_cx_amt;
				    		return $.foramtMoney((Number(num) - Number(num2)).div100());
				    	}},
				    	{field:"in_r_bz_num",title:"笔数", align:'center',width:80, formatter:function(value, row){
				    		return isNaN(value) ? 0 : value;
				    	}},
				    	{field:"in_r_bz_amt",title:"金额", align:'center',width:80, formatter:function(value, row){
				    		return $.foramtMoney(Number(value).div100());
				    	}},
				    	{field:"in_t_num",title:"笔数", align:'center',width:80, formatter:function(value){
				    		if(!value){
				    			return 0;
				    		}
				    		return value;
				    	}},
				    	{field:"in_t_amt",title:"金额", align:'center',width:80, formatter:function(value){
				    		if(!value || isNaN(value)){
				    			value = 0;
				    		}
				    		return $.foramtMoney(Number(value).div100());
				    	}},
				    	{field:"xj1",title:"笔数", align:'center',width:80, formatter:function(value, row){
				    		var num = isNaN(row.in_r_num) ? 0 : row.in_r_num;
				    		var num2 = isNaN(row.in_t_num) ? 0 : row.in_t_num;
				    		var num3 = isNaN(row.out_cx_num) ? 0 : row.out_cx_num;
				    		var num4 = isNaN(row.in_r_bz_num) ? 0 : row.in_r_bz_num;
				    		return Number(num) + Number(num2) - Number(num3) + Number(num4);
				    	}},
				    	{field:"xj2",title:"金额", align:'center',width:80, formatter:function(value, row){
				    		var amt = isNaN(row.in_r_amt) ? 0 : row.in_r_amt;
				    		var amt2 = isNaN(row.in_t_amt) ? 0 : row.in_t_amt;
				    		var amt3 = isNaN(row.out_cx_amt) ? 0 : row.out_cx_amt;
				    		var amt4 = isNaN(row.in_r_bz_amt) ? 0 : row.in_r_bz_amt;
				    		return $.foramtMoney((Number(amt) + Number(amt2) - Number(amt3) + Number(amt4)).div100());
				    	}}
					]],
			columns:[[
						{title:"支出", colspan:12, align:'center'},
			          	{field:"start_amt", title:"上期", rowspan:3, align:'center', width:"100px",formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
			            {field:"end_amt", title:"本期结余", rowspan:3, align:'center', width:"100px", formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}}
			        ],[
						{title:"消费支出", colspan:2, align:'center'},
						{title:"转账支出", colspan:2, align:'center'},
						{title:"充值撤销支出", hidden:true,colspan:2, align:'center'},
						{title:"余额返还支出", colspan:2, align:'center'},
						{title:"圈提支出", colspan:2, align:'center'},
						{title:"支出小计", colspan:2, align:'center'}
			        ],[
						{field:"out_c_num",title:"笔数", align:'center', width:"100px", formatter:function(value){
							if(!value){
								return 0;
							}
							return value;
						}},
						{field:"out_c_amt",title:"金额", align:'center', width:"100px", formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"out_t_num",title:"笔数", align:'center', width:"100px", formatter:function(value){
							if(!value){
								return 0;
							}
							return value;
						}},
						{field:"out_t_amt",title:"金额", align:'center', width:"100px", formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"out_cx_num",title:"笔数",hidden:true, align:'center', width:"100px",formatter:function(value){
							if(!value){
								return 0;
							}
							return value;
						}},
						{field:"out_cx_amt",title:"金额",hidden:true, align:'center', width:"100px",formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"out_b_num",title:"笔数", align:'center', width:"100px", formatter:function(value){
							if(!value){
								return 0;
							}
							return value;
						}},
						{field:"out_b_amt",title:"金额", align:'center', width:"100px", formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"out_qt_num",title:"笔数", align:'center', width:"100px", formatter:function(value){
							if(!value){
								return 0;
							}
							return value;
						}},
						{field:"out_qt_amt",title:"金额", align:'center', width:"100px", formatter:function(value){
							if(!value || isNaN(value)){
								value = 0;
							}
							return $.foramtMoney(Number(value).div100());
						}},
						{field:"xj3",title:"笔数", align:'center',width:80, formatter:function(value, row){
				    		var num = isNaN(row.out_c_num) ? 0 : row.out_c_num;
				    		var num2 = isNaN(row.out_t_num) ? 0 : row.out_t_num;
				    		var num4 = isNaN(row.out_b_num) ? 0 : row.out_b_num;
				    		var num5 = isNaN(row.out_qt_num) ? 0 : row.out_qt_num;
				    		return Number(num) + Number(num2) + Number(num4) + Number(num5);
				    	}},
				    	{field:"xj4",title:"金额", align:'center',width:80, formatter:function(value, row){
				    		var amt = isNaN(row.out_c_amt) ? 0 : row.out_c_amt;
				    		var amt2 = isNaN(row.out_t_amt) ? 0 : row.out_t_amt;
				    		var amt4 = isNaN(row.out_b_amt) ? 0 : row.out_b_amt;
				    		var amt5 = isNaN(row.out_qt_amt) ? 0 : row.out_qt_amt;
				    		return $.foramtMoney((Number(amt) + Number(amt2) + Number(amt4) + Number(amt5)).div100());
				    	}}
			        ]],
			onBeforeLoad:function(params){
				if(!params || !params["queryType"]){
					return false;
				}
				
				return true;
			},
			toolbar:"#tb",
			onLoadSuccess:function(data){
        	    if(data.status != 0){
        		    $.messager.alert("系统消息",data.errMsg,"error");
        		    return;
        	    }
        	    
        	    var rows = data.rows;
        	    
        	    var in_r_num = 0;
        	    var in_r_amt = 0;
        	    var in_r_bz_num = 0;
        	    var in_r_bz_amt = 0;
        	    var in_t_num = 0;
        	    var in_t_amt = 0;
        	    var out_c_num = 0;
        	    var out_c_amt = 0;
        	    var out_t_num = 0;
        	    var out_t_amt = 0;
        	    var out_cx_num = 0;
        	    var out_cx_amt = 0;
        	    var out_b_num = 0;
        	    var out_b_amt = 0;
        	    var out_qt_num = 0;
        	    var out_qt_amt = 0;
        	    var start_amt = 0;
        	    var end_amt = 0;
        	    
        	    for(var i in rows){
        	    	var row = rows[i];
        	    	in_r_num += Number(isNaN(row.in_r_num)?0:row.in_r_num);
        	    	in_r_amt += Number(isNaN(row.in_r_amt)?0:row.in_r_amt);
        	    	in_r_bz_num += Number(isNaN(row.in_r_bz_num)?0:row.in_r_bz_num);
        	    	in_r_bz_amt += Number(isNaN(row.in_r_bz_amt)?0:row.in_r_bz_amt);
        	    	in_t_num += Number(isNaN(row.in_t_num)?0:row.in_t_num);
        	    	in_t_amt += Number(isNaN(row.in_t_amt)?0:row.in_t_amt);
        	    	out_c_num += Number(isNaN(row.out_c_num)?0:row.out_c_num);
        	    	out_c_amt += Number(isNaN(row.out_c_amt)?0:row.out_c_amt);
        	    	out_t_num += Number(isNaN(row.out_t_num)?0:row.out_t_num);
        	    	out_t_amt += Number(isNaN(row.out_t_amt)?0:row.out_t_amt);
        	    	out_cx_num += Number(isNaN(row.out_cx_num)?0:row.out_cx_num);
        	    	out_cx_amt += Number(isNaN(row.out_cx_amt)?0:row.out_cx_amt);
        	    	out_b_num += Number(isNaN(row.out_b_num)?0:row.out_b_num);
        	    	out_b_amt += Number(isNaN(row.out_b_amt)?0:row.out_b_amt);
        	    	out_qt_num += Number(isNaN(row.out_qt_num)?0:row.out_qt_num);
        	    	out_qt_amt += Number(isNaN(row.out_qt_amt)?0:row.out_qt_amt);
        	    	start_amt += Number(isNaN(row.start_amt)?0:row.start_amt);
        	    	end_amt += Number(isNaN(row.end_amt)?0:row.end_amt);
        	    }
        	    
        	    var footer = {
        	    		isFooter : true,
        	    		accKind : "统计：",
        	    		in_r_num : in_r_num,
        	    		in_r_amt : in_r_amt,
        	    		in_r_bz_num : in_r_bz_num,
        	    		in_r_bz_amt : in_r_bz_amt,
        	    		in_t_num : in_t_num,
        	    		in_t_amt : in_t_amt,
        	    		out_c_num : out_c_num,
        	    		out_c_amt : out_c_amt,
        	    		out_t_num : out_t_num,
        	    		out_t_amt : out_t_amt,
        	    		out_cx_num : out_cx_num,
        	    		out_cx_amt : out_cx_amt,
        	    		out_b_num : out_b_num,
        	    		out_b_amt : out_b_amt,
        	    		out_qt_num : out_qt_num,
        	    		out_qt_amt : out_qt_amt,
        	    		start_amt : start_amt,
        	    		end_amt : end_amt
        	    };
        	    
        	    $("#dg").datagrid("reloadFooter", [footer]);
            }
		});
	});
	
	function query(){
		if(dealNull($("#startDate").val()) ==''){
			$.messager.alert('系统消息','请输入查询的起始时间','warning',function(){
				$("#startDate").focus();
			});
			return false;
		}
		if(dealNull($("#endDate").val()) ==''){
			$.messager.alert('系统消息','请输入查询的起始时间','warning',function(){
				$("#endDate").focus();
			});
			return false;
		}
		$grid.datagrid("load",{
			queryType:"0",
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val()
		});
	}
	
	function exportExcel(){
		$.messager.progress({text:"数据处理中, 请稍候..."});
		$("#download-frame").attr("src", "sysReportQuery/sysReportQueryAction!exportPayReadyRt.action?");
		$.messager.progress("close");
	}
</script>
<n:initpage title="系统备份金账户实时统计报表">
	<n:center>
		<div id="tb">
			<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width:8%">起始时间：</td>
						<td class="tableright" style="width:17%">
							<input  id="startDate" type="text" name="startDate" class="textinput" disabled="disabled" value="<%=DateUtil.formatDate(new Date(), "yyyy-MM-dd")%>"/>
						</td>
						<td class="tableleft" style="width:8%">结束时间：</td>
						<td class="tableright" style="width:17%">
							<input id="endDate" type="text"  name="endDate" class="textinput" disabled="disabled" value="<%=DateUtil.formatDate(new Date(), "yyyy-MM-dd")%>"/>
						</td>
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportExcel()">导出</a>
						</td>
					</tr>
			</table>
		</div>
  		<table id="dg" title="备份金信息"></table>
  		<iframe id='download-frame' ></iframe>
	</n:center>
</n:initpage>